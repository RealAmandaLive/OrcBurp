class_name HazardTrigger extends Area2D

signal hazard_triggered

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		hazard_triggered.emit()
