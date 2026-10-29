# applies a random physics impulse on init!
# must be put on a RigidBody2D

extends RigidBody2D

@export var fling_strength: float = 500.0
@export var spin_strength: float = 500.0

func _ready() -> void:
	# FLING!!!!
	var random_dir = Vector2(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0))
	apply_impulse(random_dir.normalized() * fling_strength)
	# TWIRL!!!!
	var random_spin = randf_range(-spin_strength, spin_strength)
	apply_torque_impulse(random_spin)
