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

var grabbed := false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var r := collision_shape.shape.get_rect()
		if event.is_pressed():
			grabbed = r.has_point(to_local(event.position))
		else:
			grabbed = false
		prints("grab", grabbed)

func _physics_process(delta: float) -> void:
	move_and_slide()
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
