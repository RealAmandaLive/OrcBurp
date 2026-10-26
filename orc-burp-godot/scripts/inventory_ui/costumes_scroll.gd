extends HBoxContainer

@onready var item_grid = $Page/MarginContainer/HBoxContainer/GridContainer
@onready var item_name_label = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer2/HBoxContainer/NameLabel
@onready var item_amount_label = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer2/HBoxContainer/AmountLabel
@onready var item_description_label = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer2/DescriptionLabel
@onready var button_primary = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer/ButtonPrimary
@onready var button_secondary = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer/ButtonSecondary
@onready var item_details = $Page/MarginContainer/HBoxContainer/ItemDetails
@onready var chara_preview = $Page/MarginContainer/HBoxContainer/CharaPreview

var selected_item : ItemSlot

var costumes = {
	"top_hat": 1,
	"wizard_hat": 1,
	"fez_hat": 1
}

func _ready() -> void:
	var item_slots = item_grid.get_children()
	
	var keys = costumes.keys()
	
	for i in range(keys.size()):
		var item_slot = item_slots[i]
		var item_data = CostumeDb.get_costume(keys[i])
		var item = {
			"id": item_data.id,
			"name": item_data.name,
			"description": item_data.description,
			"texture": item_data.texture
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
		#item_amount_label.text = "x%d" % data.amount
		item_description_label.text = data.description
		button_primary.show()
		button_secondary.show()
	else:
		item_name_label.text = ""
		item_amount_label.text = ""
		item_description_label.text = ""
		button_primary.hide()
		button_secondary.hide()


func _on_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		chara_preview.hide()
		item_details.show()
	else:
		item_details.hide()
		chara_preview.show()
