class_name GridLockPiece
extends CharacterBody2D

enum PieceDir {
	HORIZONTAL,
	VERTICAL,
}

const PIECE_SPEED = 10.0
const MAX_SPEED = 2000.0
const STOP_SPEED = 5000.0

@export var has_key := false
@export var movement := PieceDir.HORIZONTAL

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_particles: CPUParticles2D = %CollisionParticles
@onready var collision_sound: AudioStreamPlayer2D = %CollisionSound

var grabbed := false
var last_collision := Vector2.INF

func _ready() -> void:
	collision_particles.emitting = false
	collision_particles.one_shot = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var r := collision_shape.shape.get_rect()
		if event.is_pressed():
			grabbed = r.has_point(to_local(event.position))
		else:
			grabbed = false

func _physics_process(delta: float) -> void:
	if velocity.length() > 0:
		if move_and_slide():
			var col := get_slide_collision(0)
			var colrect: Rect2 = collision_shape.shape.get_rect()
			if collision_particles and not col.get_position().is_equal_approx(last_collision):
				collision_particles.global_position = col.get_position()
				collision_sound.global_position = col.get_position()
				if movement == PieceDir.HORIZONTAL:
					collision_particles.emission_rect_extents = Vector2(1.0, colrect.size.y / 2.0)
					collision_particles.global_position.y = global_position.y
				else:
					collision_particles.emission_rect_extents = Vector2(colrect.size.x / 2.0, 1.0)
					collision_particles.global_position.x = global_position.x
				collision_particles.restart()
				collision_sound.play()
				last_collision = col.get_position()
		else:
			last_collision = Vector2.INF			
	if grabbed:
		velocity = (get_global_mouse_position() - global_position) * PIECE_SPEED
		if movement == PieceDir.HORIZONTAL:
			velocity.y = 0
		else:
			velocity.x = 0
		if velocity.length() > MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * STOP_SPEED)
