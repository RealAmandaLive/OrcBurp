extends Area2D

const DAMAGE: int = 1

var velocity = Vector2(0, 0)

func _process(delta: float) -> void:
	velocity.y += get_gravity() * delta
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
