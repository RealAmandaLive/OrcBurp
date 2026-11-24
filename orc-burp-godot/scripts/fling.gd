# applies a random physics impulse on init!
# must be put on a RigidBody2D

extends RigidBody2D

@export var fling_strength: float = 600.0
@export var spin_strength: float = 1200.0

var prev_vel = Vector2(0,0)
var minBounceForSound = 40

func _ready() -> void:
	# leave parent so it moves independently
	reparent.call_deferred(get_parent().get_parent())

	# FLING!!!!
	# var random_dir = Vector2(randf_range(-1.0, 1.0),randf_range(-1.0, 1.0)) # any dir
	var random_dir = Vector2(randf_range(-1.0, 1.0),randf_range(-2.0, -1.0)) # only upwards
	apply_impulse(random_dir.normalized() * fling_strength)
	
	# TWIRL!!!!
	var random_spin = randf_range(-spin_strength, spin_strength)
	apply_torque_impulse(random_spin)

func maybe_bounce() -> void:
	var velDelta = linear_velocity.distance_to(prev_vel)
	if abs(velDelta)>minBounceForSound:
		# print("bounce strength = "+str(velDelta))
		if $bounceSound: 
			if not $bounceSound.playing:
				$bounceSound.play()

func _process(delta: float) -> void:
	maybe_bounce()
