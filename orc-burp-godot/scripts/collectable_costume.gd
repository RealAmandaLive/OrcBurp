@tool
class_name CollectableCostume
extends Node2D

@export var costume_data: CostumeData:
	set(v):
		costume_data = v
		update_texture()


@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pickup_area: Area2D = $PickupArea


func _ready() -> void:
	pickup_area.body_entered.connect(_on_body_entered)
	update_texture.call_deferred()

	# if this item was previously collected and we're loading
	# a saved game or revisiting this room after the initial collection
	# the item should not be present this time around
	if not Engine.is_editor_hint():
		if Main.data.is_item_taken(self):
			hide()
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# TODO play a sound
		Main.data.add_costume_to_collection(costume_data.id)
		Main.data.record_item_taken(self)
		queue_free()


func update_texture() -> void:
	if sprite_2d and costume_data.texture:
		sprite_2d.texture = costume_data.texture
