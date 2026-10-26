extends HBoxContainer

@onready var item_name_label = %NameLabel
@onready var item_amount_label = %AmountLabel
@onready var item_description_label = %DescriptionLabel
@onready var button_primary = %ButtonPrimary
@onready var button_secondary = %ButtonSecondary

var selected_item : ItemSlot

var items = [
	{
		"name": "apple",
		"amount": 4,
		"description": "A red apple that fills your belly and heart."
	},
	{
		"name": "bread loaf",
		"amount": 2,
		"description": "A warm, crusty loaf of bread fresh from the oven."
	},
	{
		"name": "health potion",
		"amount": 5,
		"description": "A glowing crimson liquid that rapidly restores health."
	},
	{
		"name": "iron key",
		"amount": 1,
		"description": "An old, rusty iron key that looks like it opens a heavy door."
	},
	{
		"name": "magic scroll",
		"amount": 3,
		"description": "An ancient parchment inscribed with glowing, mysterious runes."
	},
	{
		"name": "copper coin",
		"amount": 50,
		"description": "A standard coin used for small transactions in local markets."
	},
	{
		"name": "wooden shield",
		"amount": 1,
		"description": "A sturdy wooden shield reinforced with iron bands."
	}
]

func _ready() -> void:
	var item_slots = %ItemsGrid.get_children()
	
	for i in range(items.size()):
		var item_slot = item_slots[i]
		item_slot.set_item_data(items[i])

func _on_item_slot_selected(item_slot: ItemSlot, data):
	if selected_item:
		selected_item.toggle()
	
	item_slot.toggle()
	selected_item = item_slot
	
	if data:
		item_name_label.text = data.name
		item_amount_label.text = "x%d" % data.amount
		item_description_label.text = data.description
	else:
		item_name_label.text = ""
		item_amount_label.text = ""
		item_description_label.text = ""
