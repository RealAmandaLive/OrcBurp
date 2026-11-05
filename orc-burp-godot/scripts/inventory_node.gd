extends Node

@onready var inventory_ui = $"../Inventory"

func _input(event):
	if event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			get_tree().paused = false
			inventory_ui.hide()
		else:
			get_tree().paused = true
			inventory_ui.show()
	
	if event.is_action_pressed("ui_accept"):
		if get_tree().paused:
			var main: Main = get_parent()
			main.data.add_item_to_inventory("key", 1)
			main.data.add_costume_to_collection("top_hat")
	
	if event.is_action_pressed("ui_up"):
		if get_tree().paused:
			var main: Main = get_parent()
			main.data.remove_item_from_inventory("key", 1)
