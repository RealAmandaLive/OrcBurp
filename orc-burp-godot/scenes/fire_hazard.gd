extends Area2D

const DAMAGE: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
	
