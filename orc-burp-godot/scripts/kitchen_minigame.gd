class_name KitchenGame extends Node2D

const STARTING_WAVE_INTERVAL: float = 20.0
const ALLOW_QUEUEING: bool = true

func p(args): print_rich("[bgcolor=ORANGE][color=BLACK]Kitchen Game: ", args)

@export var seats: Array[Node2D]
@export var oven: KitchenOven
@export var entrance: Node2D
@export var queue_line: Node2D
@export var ingredients: Array[KitchenIngredient]

@export var hud_inventory_list: VBoxContainer

var customers_satisfied: int = 0:
	set(v):
		customers_satisfied = v
		p("-- %d total satisfied customers." % customers_satisfied)
	
var customers_abandoned: int = 0:
	set(v):
		customers_abandoned = v
		p("-- %d total unhappy customers." % customers_abandoned)

var tips_earned: int = 0:
	set(v):
		tips_earned = v
		p("-- %d total tips earned." % tips_earned)

var player_inventory: Array

var spawner: Timer
var current_interval: float
var queue: Array[Customer]

var _seated: Dictionary[Node2D, Customer] = {}


#region Customer class
class Customer extends Node2D:
	signal player_interacted
	signal ready_to_leave
	signal lost_patience
	
	const META_INTERACT_ENTER = &"on_interact_enter"
	const META_INTERACT_EXIT = &"on_interact_exit"
	var RED_INDICATOR_COLOR: Color:
		get: return Color.RED.lightened(0.35) ## hack bc I'm too lazy to write down a constant value
	
	var desire: Desire
	var patience: ProgressBar
	var received_order: bool = false
	
	var moving: Tween
	var interaction: Area2D
	var display_text_label: Label
	
	func _init():
		## Make a visual
		const SCENE = preload("uid://bbxk1xg5yi17m") ## kinda HACK gut sprite scene
		var sprite := SCENE.instantiate() as AnimatedSprite2D
		sprite.scale = Vector2.ONE * 2.0;  sprite.modulate = Color.GOLD
		add_child(sprite)
		
		name = "Customer"
		
	func _unhandled_input(event: InputEvent) -> void:
		if not interaction:
			return
		if event.is_action_pressed(&"interact"):
			var player = get_tree().get_first_node_in_group(Main.PLAYER_GROUP)
			if not player: return
			if player in interaction.get_overlapping_bodies():
				player_interacted.emit()
				get_viewport().set_input_as_handled()
	
	## Sit at a seat, then get ready to order.
	func sit_at(seat: Node2D):
		const SPEED: int = 96 ## pixels per second
		var distance: float = (seat.global_position - self.global_position).length()
		
		if moving:
			moving.kill()
		moving = create_tween()
		moving.tween_property(self, ^"modulate", Color.WHITE, 1.0).from(Color.BLACK)
		moving.tween_property(self, ^"global_position", seat.global_position, distance / SPEED)
		moving.tween_callback(_just_seated)
	
	func exit_at(exit: Node2D):
		const SPEED: int = 96 ## pixels per second
		var distance: float = (exit.global_position - self.global_position).length()
		
		if moving:
			moving.kill()
		moving = create_tween()
		moving.tween_property(self, ^"global_position", exit.global_position, distance / SPEED)
		moving.tween_property(self, ^"modulate", Color.BLACK, 1.0)
		moving.tween_callback(queue_free)
	
	## Fancy countdown with visible progress bar
	func think_then_do(callback: Callable, duration: float) -> Tween:
		const THINKER_SIZE := Vector2(64.0, 8.0)
		var thinker = ProgressBar.new()
		thinker.position.y = -64.0
		thinker.position.x -= THINKER_SIZE.x / 2.0
		thinker.custom_minimum_size = THINKER_SIZE
		add_child(thinker)
		
		var thinking := create_tween()
		thinking.tween_property(thinker, ^"value", 100.0, duration)
		thinking.tween_callback(thinker.queue_free)
		thinking.tween_callback(callback)
		return thinking
	
	func start_patience(duration: float):
		if patience:
			patience.queue_free()
		
		const THINKER_SIZE := Vector2(64.0, 8.0)
		patience = ProgressBar.new()
		patience.position.y = -64.0
		patience.position.x -= THINKER_SIZE.x / 2.0
		patience.custom_minimum_size = THINKER_SIZE
		patience.show_percentage = false
		patience.modulate = RED_INDICATOR_COLOR
		add_child(patience)
		
		var thinking := patience.create_tween()
		thinking.tween_property(patience, ^"value", 0.0, duration).from(100.0)
		thinking.tween_callback(patience.queue_free)
		thinking.tween_callback(_ran_out_of_patience)
		return thinking
	
	func display_text(text: String, resize: float = 1.0, recolor: Color = Color.WHITE, show_panel: bool = true):
		if not display_text_label:
			## Make a panel with a label
			var display_text_panel := PanelContainer.new()
			display_text_panel.position.y = -110.0
			display_text_panel.position.x = -2.0
			
			display_text_label = Label.new()
			display_text_panel.add_child(display_text_label)
			
			add_child(display_text_panel)
		
		display_text_label.modulate = recolor
		display_text_label.text = text
		
		var panel: PanelContainer = display_text_label.get_parent()
		panel.self_modulate = Color.WHITE if show_panel else Color.TRANSPARENT
		panel.scale = Vector2.ONE * resize
		panel.show()
	
	func hide_text():
		if display_text_label:
			display_text_label.get_parent().hide()
	
	func ready_to_order():
		display_text("!", 2.0, RED_INDICATOR_COLOR, false)
		_generate_interact_box(_display_order, _display_indicator)
		start_patience(25.0 + (desire.ingredients.size() * 10.0))
		
	func deliver_order():
		received_order = true
		if patience: patience.queue_free()
		interaction.free()
		display_text("*satisfied*")
		think_then_do(ready_to_leave.emit, randfn(5.0 * desire.ingredients.size(), 3.0))
	
	func _just_seated():
		think_then_do(ready_to_order, randfn(9.0, 4.5))
		
	func _ran_out_of_patience():
		if received_order: return ## fluke
		lost_patience.emit()
		ready_to_leave.emit()
		
	func _display_order():
		display_text("I'll have a %s." % desire)
	
	func _display_indicator():
		display_text("!", 2.0, RED_INDICATOR_COLOR, false)
	
	## Set up an Area2D with collision.
	func _generate_interact_box(enter_callback: Callable, exit_callback: Callable):
		if interaction: return
		interaction = Area2D.new()
		
		var shape := CircleShape2D.new();  shape.radius = 64.0
		var collision := CollisionShape2D.new();  collision.shape = shape
		interaction.add_child(collision)
		add_child(interaction)
		
		interaction.set_meta(META_INTERACT_ENTER, enter_callback)
		interaction.set_meta(META_INTERACT_EXIT, exit_callback)
		interaction.body_entered.connect(_on_interact_entered)
		interaction.body_exited.connect(_on_interact_exited)
	
	func _on_interact_entered(body: Node2D):
		if body is Player:
			var callable: Callable = interaction.get_meta(META_INTERACT_ENTER)
			if callable: callable.call()
	
	func _on_interact_exited(body: Node2D):
		if body is Player:
			var callable: Callable = interaction.get_meta(META_INTERACT_EXIT)
			if callable: callable.call()
	
#endregion

#region Desire (recipe) class
class Desire:
	const MAX_INGREDIENTS: int = 5
	var ingredients: Array[String] = []
	
	func _init(available_ingredients: Array):
		assert(not available_ingredients.is_empty())
		var number_to_pick: int = randi_range(1, MAX_INGREDIENTS)
		
		for i in number_to_pick:
			ingredients.append(available_ingredients.pick_random())
	
	func _to_string() -> String:
		var to_return: String = ""
		for ing in ingredients:
			if not to_return.is_empty():
				to_return += ", "
			to_return += "%s" % ing
		to_return = "(" + to_return + ")"
		return to_return
#endregion


func _ready():
	await create_tween().tween_interval(3.0).finished
	start_game()

func start_game():
	const MISSING = "Missing a required node. Check export properties"
	assert(seats, MISSING)
	assert(oven, MISSING)
	assert(queue_line, MISSING)
	assert(entrance, MISSING)
	assert(ingredients, MISSING)
	assert(not spawner)
	
	for ing: KitchenIngredient in ingredients:
		ing.collected.connect(_on_ingredient_collected)
		
	oven.player_interacted.connect(_on_oven_interacted)
	
	_seated.clear()
	spawn_customer()
	
	spawner = Timer.new();  add_child(spawner)
	spawner.timeout.connect(_on_spawner_timeout)
	spawner.start(STARTING_WAVE_INTERVAL)
	p("Started spawner.")
	
func find_seat() -> Node2D:
	var empty_seats: Array[Node2D] = seats.filter(
		func(v: Node2D):
			return not (v in _seated.keys())
	)
	if empty_seats.is_empty():
		return null
	else:
		return empty_seats.pick_random()

func spawn_customer():
	p("Spawning a customer")
	
	var seat = find_seat()
	var queueing: bool = (seat == null)
	
	var new_customer = Customer.new()
	
	## Convert our ingredient list into strings
	var available: Array[String]
	for i in ingredients:
		available.append(i.name)
	
	new_customer.desire = Desire.new(available)
	
	new_customer.player_interacted.connect(_on_customer_interacted.bind(new_customer))
	new_customer.ready_to_leave.connect(_on_customer_ready_to_leave.bind(new_customer))
	new_customer.lost_patience.connect(_on_customer_lost_patience.bind(new_customer))
	
	new_customer.global_position = entrance.global_position
	add_child(new_customer)
	
	await create_tween().tween_interval(0.5).finished
	
	if not queueing:
		_seated[seat] = new_customer
		new_customer.sit_at(seat)
	else:
		var t = new_customer.create_tween()
		t.tween_property(
			new_customer,
			^"global_position",
			queue_line.global_position + (queue.size() * 16.0 * Vector2.RIGHT),
			1.2)
		queue.append(new_customer)

func temp_popup_label(global_location: Vector2, text: String, duration: float):
	var pc := PanelContainer.new()
	var label := Label.new()
	pc.add_child(label)
	label.text = text
	pc.global_position = global_location
	pc.light_mask = 0;  pc.top_level = true
	add_child(pc)
	
	var t := pc.create_tween()
	t.tween_interval(duration)
	t.tween_property(pc, ^"modulate", Color.TRANSPARENT, 1.25)
	t.tween_callback(pc.queue_free)

func update_inventory_hud():
	if not hud_inventory_list: return
	for child in hud_inventory_list.get_children():
		child.queue_free()
	for item in player_inventory:
		var l = Label.new()
		l.autowrap_mode = TextServer.AUTOWRAP_WORD
		l.text = str(item)
		hud_inventory_list.add_child(l)

func _on_spawner_timeout():
	if (not _seated.size() >= seats.size()) or ALLOW_QUEUEING:
		spawn_customer()
	current_interval *= 0.94
	spawner.start(current_interval)
	
func _on_ingredient_collected(ingredient: KitchenIngredient):
	const UI_OFFSET = Vector2(-36.0, -64.0)
	p("Player collected one %s." % ingredient.name)
	
	player_inventory.append(ingredient.name)
	update_inventory_hud()
	
	var text: String = "Got %s" % ingredient.name
	var number_of: int = player_inventory.count(ingredient.name)
	if number_of > 1:
		text = text + "(%d)" % number_of
	
	temp_popup_label(ingredient.global_position + UI_OFFSET, text, 1.0)

func _on_oven_interacted():
	const UI_OFFSET = Vector2(-36.0, -96.0)
	p("Player interacted with oven.")
	
	var items = player_inventory.filter(func(v): return not v is Array)
	
	if oven.baking:
		if oven.baking.is_running():
			return
	
	if oven.output:
		var output: Array[String] = oven.empty()
		
		player_inventory.append(output)
		update_inventory_hud()
		
		temp_popup_label(oven.global_position + UI_OFFSET, "Took cooked item:\n" + str(output), 2.0)
	
	elif items.is_empty():
		if not oven.ingredients.is_empty():
			## Run the oven
			oven.bake()
			temp_popup_label(oven.global_position + UI_OFFSET, "Baking...", 2.0)
		else:
			## We got nothin
			temp_popup_label(oven.global_position + UI_OFFSET, "It's empty!", 0.8)
	
	else:
		## Add ingredients
		## Prevent too many ingredients added
		if oven.ingredients.size() < Desire.MAX_INGREDIENTS:
			var item = items.pop_back()
			
			player_inventory.erase(item)
			update_inventory_hud()
			
			oven.add_ingredient(item)
			temp_popup_label(oven.global_position + UI_OFFSET, "Added %s" % item, 2.0)
	
func _on_customer_interacted(customer: Customer):
	if customer.received_order: return # unlikely but
	
	p("Player interacted with %s." % customer)
	## Check if we have something to give to this guy
	if player_inventory.is_empty():
		## Nope
		customer.display_text("..?")
		return
	else:
		for item in player_inventory:
			if item is Array:
				if item.size() == customer.desire.ingredients.size():
					var to_match := customer.desire.ingredients.duplicate()
					for i in item:
						if to_match.has(i):
							to_match.erase(i)
					
					if to_match.is_empty():
						## Yes
						customers_satisfied += 1
						var tip: int = randi_range(0, item.size())
						tips_earned += tip
						var tips_text: String
						if not tips_earned:
							tips_text = "(no gratuity)"
						else:
							tips_text = "tipped +%d" % tip
						
						customer.deliver_order()
						
						player_inventory.erase(item)
						update_inventory_hud()
						
						p("Player delivered order to %s." % customer)
						
						temp_popup_label(customer.global_position + Vector2(-32.0, -96.0), "Delivered!\n" + tips_text, 3.0)
						return
		
		customer.display_text("That's not what I ordered...")
		p("Customer desires %s; player has %s" % [customer.desire, player_inventory])

func _on_customer_ready_to_leave(customer: Customer):
	customer.exit_at(entrance)
	_seated.erase(_seated.find_key(customer))
	
	if not queue.is_empty():
		var seat = find_seat()
		if not seat:
			return
		
		var first_in: Customer = queue.pop_front()
		_seated[seat] = first_in
		first_in.sit_at(seat)
		

func _on_customer_lost_patience(_customer: Customer):
	customers_abandoned += 1
