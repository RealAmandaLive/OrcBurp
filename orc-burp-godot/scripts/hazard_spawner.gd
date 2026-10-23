class_name HazardSpawner extends Node2D

@export var scene_to_spawn: PackedScene

func _on_hazard_triggerd() -> void:
	var scene = scene_to_spawn.instantiate()
	get_parent().add_child(scene)
	scene.global_position = global_position
