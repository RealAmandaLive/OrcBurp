extends Node

func _input(event):
	if event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true
