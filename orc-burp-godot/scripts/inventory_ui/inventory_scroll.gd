extends HBoxContainer

@onready var item_name_label = %NameLabel
@onready var item_amount_label = %AmountLabel
@onready var item_description_label = %DescriptionLabel
@onready var button_primary = %ButtonPrimary
@onready var button_secondary = %ButtonSecondary

var selected_item : ItemSlot

var items = {
	"potion": 5,
	"key": 10
}

func _ready() -> void:
	var item_slots = %ItemsGrid.get_children()
	
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
	
	reset()

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
