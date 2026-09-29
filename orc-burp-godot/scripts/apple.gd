extends Area2D

@export var health_given_when_collected: int = 1

var collected: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _on_body_entered(_body: Node2D) -> void:
	if collected:
		return
	if _body is Player:
		collected = true
		_body.collect_apple(health_given_when_collected)
		animated_sprite_2d.animation = "collected"
		call_deferred("_disable_collision")
	

func _disable_collision() -> void:
	collision_shape_2d.disabled = true


func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "collected":
		queue_free()
