extends Node2D

@export var spin_degrees_per_second = 90.0

func _process(delta: float) -> void:
	rotation += deg_to_rad(spin_degrees_per_second) * delta
