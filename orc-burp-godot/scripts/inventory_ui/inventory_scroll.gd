extends HBoxContainer

@onready var item_name_label = %NameLabel
@onready var item_amount_label = %AmountLabel
@onready var item_description_label = %DescriptionLabel
@onready var button_primary: Control = %ButtonPrimary
@onready var button_secondary: Control = %ButtonSecondary

var selected_item : ItemSlot
var item_slots

func _ready() -> void:
	item_slots = %ItemsGrid.get_children()
	button_primary.gui_input.connect(_on_primary_button_pressed)
	button_secondary.gui_input.connect(_on_secondary_button_pressed)
	reset()

func set_items(items):
	clear_items()
	
	var keys = items.keys()
	
	for i in range(keys.size()):
		var item_slot = item_slots[i]
		var item_data = ItemDb.get_item(keys[i])
		var item = {
			"id": item_data.id,
			"name": item_data.name,
			"description": item_data.description,
			"texture": item_data.texture,
			"amount": items[keys[i]]
		}
		item_slot.set_item_data(item)

func clear_items():
	for slot in item_slots:
		slot.clear()

func fold():
	$Page.hide()
	reset()

func unfold():
	$Page.show()

func reset():
	item_name_label.text = ""
	item_amount_label.text = ""
	item_description_label.text = ""
	button_primary.hide()
	button_secondary.hide()
	if selected_item:
		selected_item.toggle()
		selected_item = null

func _on_item_slot_selected(item_slot: ItemSlot, data):
	if selected_item:
		selected_item.toggle()
	
	item_slot.toggle()
	selected_item = item_slot
	
	if data:
		item_name_label.text = data.name
		item_amount_label.text = "x%d" % data.amount
		item_description_label.text = data.description
		button_primary.show()
		button_secondary.show()
	else:
		item_name_label.text = ""
		item_amount_label.text = ""
		item_description_label.text = ""
		button_primary.hide()
		button_secondary.hide()


func _on_primary_button_pressed(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and selected_item:
			# TODO: play a sound
			var item: ItemData = ItemDb.get_item(selected_item.item_data.id)
			if item:
				item.apply_item_effect()
			Main.data.remove_item_from_inventory(selected_item.item_data.id, 1)


func _on_secondary_button_pressed(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# TODO: play a sound
			# TODO: does the item need to go back into the world as a collectable?
			Main.data.remove_item_from_inventory(selected_item.item_data.id, 1)
