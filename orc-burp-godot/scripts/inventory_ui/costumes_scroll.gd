extends HBoxContainer

@onready var item_grid = $Page/MarginContainer/HBoxContainer/GridContainer
@onready var item_name_label = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer2/HBoxContainer/NameLabel
@onready var item_name_label2 = $Page/MarginContainer/HBoxContainer/CharaPreview2/VBoxContainer2/NameLabel
@onready var item_amount_label = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer2/HBoxContainer/AmountLabel
@onready var item_description_label = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer2/DescriptionLabel
@onready var item_description_label2 = $Page/MarginContainer/HBoxContainer/CharaPreview2/VBoxContainer2/DescriptionLabel
@onready var button_primary = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer/ButtonPrimary
@onready var button_secondary = $Page/MarginContainer/HBoxContainer/ItemDetails/VBoxContainer/ButtonSecondary
@onready var item_details = $Page/MarginContainer/HBoxContainer/ItemDetails
@onready var chara_preview = $Page/MarginContainer/HBoxContainer/CharaPreview
#@onready var hat_sprite: Sprite2D = %HatSprite
@onready var hat_sprite: Sprite2D = $Page/MarginContainer/HBoxContainer/CharaPreview2/TextureRect/HatSprite

var selected_item : ItemSlot
var item_slots

func _ready() -> void:
	item_slots = item_grid.get_children()
	reset()

func set_items(costumes):
	clear_items()
	
	var keys = costumes.keys()

	for i in range(keys.size()):
		var item_slot = item_slots[i]
		var item_data = CostumeDb.get_costume(keys[i])
		var item = {
			"id": item_data.id,
			"name": item_data.name,
			"description": item_data.description,
			"texture": item_data.texture,
			"texture_offset": item_data.texture_offset,
		}
		item_slot.set_item_data(item)
		if Main.data.active_costume == item_data.id:
			_on_item_slot_selected(item_slot, item)

func clear_items():
	for slot in item_slots:
		slot.clear()

func fold():
	$Page.hide()
	reset()

func unfold():
	$Page.show()

func reset():
	hat_sprite.hide()
	item_name_label.text = ""
	item_description_label.text = ""
	item_name_label2.text = "No hat"
	item_description_label2.text = "Maybe Gut can find something to wear if he looks around."
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
		item_name_label2.text = data.name
		item_description_label.text = data.description
		item_description_label2.text = data.description
		button_primary.show()
		button_secondary.show()
		hat_sprite.show()
		hat_sprite.texture = data.texture
		hat_sprite.offset = data.texture_offset
		Main.data.active_costume = data.id
	else:
		item_name_label.text = ""
		item_name_label2.text = ""
		item_description_label.text = ""
		item_description_label2.text = ""
		button_primary.hide()
		button_secondary.hide()
		hat_sprite.hide()
		Main.data.active_costume = ""


func _on_toggle_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		chara_preview.hide()
		item_details.show()
	else:
		item_details.hide()
		chara_preview.show()


func _on_primary_button_pressed(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and selected_item:
			Main.data.active_costume = selected_item.item_data.id


func _on_secondary_button_pressed(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# TODO: play a sound
			Main.data.active_costume = ""
