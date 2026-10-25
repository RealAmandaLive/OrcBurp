@tool
extends Node

@onready var rect: NinePatchRect = $"../NinePatchRect"
@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"

var piece: GridLockPiece

func _ready() -> void:
	piece = get_parent()
	_update_sizes()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_sizes()

func _update_sizes() -> void:
	rect.size = piece.size
	rect.position = piece.size * -0.5
	if piece.size != collision_shape.shape.get_rect().size:
		collision_shape.shape = collision_shape.shape.duplicate()
		collision_shape.shape.size = piece.size
