extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var knockback_applier: KnockbackApplier = $KnockbackApplier

const DAMAGE: int = 1
const SPEED = 100
var direction = -1.0

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if not knockback_applier.active:
		position.x += direction * SPEED * delta

func _on_timer_timeout() -> void:
	direction *= -1
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)


func apply_knockback(horizontal_force:float) -> void:
	knockback_applier.start(horizontal_force)
