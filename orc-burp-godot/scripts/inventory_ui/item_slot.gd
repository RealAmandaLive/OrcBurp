extends TextureRect
class_name ItemSlot

signal selected(node, data)

@export var root_parent : Control
@export var is_costume := false

@onready var amount_label = $AmountLabel
@onready var item_texture_rect = $ItemTexture
@onready var select_overlay = $SelectOverlay

var is_selected = false
var item_texture : Texture
var item_data

func _ready() -> void:
	#print(root_parent.has_method("_on_item_slot_selected"))
	selected.connect(root_parent._on_item_slot_selected)

func toggle():
	is_selected = !is_selected
	if is_selected:
		select_overlay.show()
	else:
		select_overlay.hide()

func set_item_data(data):
	item_data = data
	if item_data.has("amount"):
		amount_label.text = "%d" % item_data.amount
	if is_costume:
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = data.texture
		atlas.region = Rect2(0, 0, 32, 32)
		item_texture_rect.texture = atlas
	else:
		item_texture_rect.texture = data.texture

func clear():
	item_data = null
	amount_label.text = ""
	item_texture_rect.texture = null


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected.emit(self, item_data)
	pass # Replace with function body.
