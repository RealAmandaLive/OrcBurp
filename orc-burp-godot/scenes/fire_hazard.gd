extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const DAMAGE: int = 1

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)


func apply_knockback() -> void:
	print("knockback applied")
