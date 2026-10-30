extends Node2D

@export var seconds_until_deleted = 5.0

func _ready() -> void:
	await get_tree().create_timer(seconds_until_deleted).timeout
	queue_free()
