class_name KitchenOven extends Area2D

signal player_interacted

var ingredients: Array
var output: Array[String] = []

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
	
func bake():
	output.assign(ingredients)
	ingredients.clear()
	print("Baked oven ingredients.")

func empty() -> Array[String]:
	var to_return = output.duplicate()
	output.clear()
	print("Emptied oven output.")
	return to_return
