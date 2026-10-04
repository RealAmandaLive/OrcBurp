class_name KitchenGame extends Node2D

const STARTING_WAVE_INTERVAL: float = 20.0

@export var seats: Array[Node2D]
@export var oven: Node2D
@export var entrance: Node2D

var customers: Array[Customer]

var spawner: Timer
var current_interval: float

var _seated: Dictionary[Node2D, Customer] = {}

func p(args): print_rich("[bgcolor=ORANGE][color=BLACK]Kitchen Game: ", args)

#region Customer class
class Customer extends Node2D:
	const META_INTERACT_ENTER = &"on_interact_enter"
	const META_INTERACT_EXIT = &"on_interact_exit"
	var RED_INDICATOR_COLOR: Color:
		get: return Color.RED.lightened(0.35) ## hack bc I'm too lazy to write down a constant value
	
	var desire
	
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
	
	## Sit at a seat, then get ready to order.
	func sit_at(seat: Node2D):
		const SPEED: int = 64 ## pixels per second
		var distance: float = (seat.global_position - self.global_position).length()
		
		if moving:
			moving.kill()
		moving = create_tween()
		moving.tween_property(self, ^"global_position", seat.global_position, distance / SPEED)
		moving.tween_callback(_just_seated)
	
	## Fancy countdown with visible progress bar
	func think_then_do(callback: Callable, duration: float):
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
	
	func display_text(text: String, resize: float = 1.0, recolor: Color = Color.WHITE, show_panel: bool = true):
		if not display_text_label:
			## Make a panel with a label
			var display_text_panel := PanelContainer.new()
			display_text_panel.position.y = -96.0
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
		desire = ["hock of prey", "filled goblet", "bowl of kibbles", "stringed beast", "cheese stew"].pick_random()
		display_text("!", 2.0, RED_INDICATOR_COLOR, false)
		_generate_interact_box(_display_order, _display_indicator)
	
	func _just_seated():
		think_then_do(ready_to_order, randfn(9.0, 4.5))
		
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

func _ready():
	await create_tween().tween_interval(3.0).finished
	start_game()

func start_game():
	const MISSING = "Missing a required node. Check export properties"
	assert(seats, MISSING)
	#assert(oven, MISSING)
	assert(entrance, MISSING)
	assert(not spawner)
	
	_seated.clear()
	spawn_customer()
	
	spawner = Timer.new();  add_child(spawner)
	spawner.timeout.connect(_on_spawner_timeout)
	spawner.start(STARTING_WAVE_INTERVAL)
	p("Started spawner.")

func spawn_customer():
	p("Spawning a customer")
	
	var empty_seats: Array[Node2D] = seats.filter(
		func(v: Node2D):
			return not (v in _seated.keys())
	)
	
	if empty_seats.is_empty():
		p("Couldn't find an available seat.")
		return
	
	var seat = empty_seats.pick_random()
	var new_customer = Customer.new()
	_seated[seat] = new_customer
	
	new_customer.global_position = entrance.global_position
	add_child(new_customer)
	
	await create_tween().tween_interval(0.5).finished
	new_customer.sit_at(seat)

func _on_spawner_timeout():
	if not customers.size() >= seats.size():
		spawn_customer()
	spawner.start(current_interval)
