class_name KitchenIngredient extends Area2D

signal collected(ingredient: KitchenIngredient)

var debouncer: Tween

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact"):
		var player = get_tree().get_first_node_in_group(Main.PLAYER_GROUP)
		if not player: return
		if player in get_overlapping_bodies():
			collect_one()
			get_viewport().set_input_as_handled()

func collect_one():
	if debouncer:
		if debouncer.is_running():
			return
	
	debouncer = create_tween()
	debouncer.tween_interval(0.15)
	collected.emit(self)
