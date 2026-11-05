extends CanvasLayer

@onready var inventory_scroll = %InventoryScroll
@onready var costumes_scroll = %CostumesScroll
var main: Main

func _ready() -> void:
	main = get_parent()
	main.data.changed.connect(update_data)
	update_data()

func update_data():
	inventory_scroll.set_items(main.data.inventory_items)
	costumes_scroll.set_items(main.data.costumes_collection)
	pass

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
