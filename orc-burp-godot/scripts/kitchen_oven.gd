class_name KitchenOven extends Area2D

signal player_interacted

var ingredients: Array
var output: Array[String] = []

var baking: Tween

var debouncer: Tween

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		var player = get_tree().get_first_node_in_group(Main.PLAYER_GROUP)
		if not player: return
		if player in get_overlapping_bodies():
			if debouncer:
				if debouncer.is_running():
					return
			debouncer = create_tween()
			debouncer.tween_interval(0.1)
			player_interacted.emit()
			get_viewport().set_input_as_handled()

func add_ingredient(what: String):
	ingredients.push_back(what)
	print("Added %s to oven." % what)

var bake_progress_bar: ProgressBar
func bake():
	if baking and baking.is_running():
		return
	
	var duration: float = 1.0 + (ingredients.size() * 3.0)
	
	bake_progress_bar = ProgressBar.new()
	bake_progress_bar.position.x -= 32.0
	bake_progress_bar.position.y -= 64.0
	bake_progress_bar.custom_minimum_size = Vector2(64, 8.0)
	add_child(bake_progress_bar)
	
	baking = create_tween()
	baking.tween_property(bake_progress_bar, ^"value", 100.0, duration)
	await baking.finished
	
	output.assign(ingredients)
	ingredients.clear()
	print("Baked oven ingredients.")

func empty() -> Array[String]:
	if bake_progress_bar: bake_progress_bar.queue_free()
	
	var to_return = output.duplicate()
	output.clear()
	print("Emptied oven output.")
	return to_return
