class_name HazardSpawner extends Node2D

@export var scene_to_spawn: PackedScene

func _on_hazard_triggerd() -> void:
	# Fix "Can't change this state while flushing queries" error when add_child is called
	# the hazard trigger fires during the physics tick and the parent is a physics object and cannot change certain state during its tick
	# The standard solution is to use "deferred" which runs at idle time during the end of the frame
	# See https://forum.godotengine.org/t/error-can-t-change-this-state-while-flushing-queries/81535
	_spawn_scene.call_deferred()

func _spawn_scene() -> void:
	var parent := get_parent()
	if not parent:
		return
	
	var scene := scene_to_spawn.instantiate()
	parent.add_child(scene)
	scene.global_position = global_position
