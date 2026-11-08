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
	
	# -----
	# for debugging inventory function only
	# -----
	
	if event.is_action_pressed("ui_accept"):
		if get_tree().paused:
			for item in ItemDb.items:
				Main.data.add_item_to_inventory(item.id, 1)
			for costume in CostumeDb.costumes:
				Main.data.add_costume_to_collection(costume.id)

	# ----
	# end
	# ---
