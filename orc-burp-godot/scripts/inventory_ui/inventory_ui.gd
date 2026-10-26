extends CanvasLayer

@onready var inventory_scroll = %InventoryScroll
@onready var costumes_scroll = %CostumesScroll


func _on_costumes_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			inventory_scroll.fold()
			costumes_scroll.unfold()


func _on_inventory_scroll_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			inventory_scroll.unfold()
			costumes_scroll.fold()
