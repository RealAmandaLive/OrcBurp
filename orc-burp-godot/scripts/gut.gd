class_name Player
extends CharacterBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound


const SPEED = 300.0
const JUMP_VELOCITY = -850.0
const CLIMBING_SPEED = -300
const DESCENDING_SPEED = 400

var alive = true
var can_move = true
var can_climb = false
var climbing = false

func _physics_process(delta: float) -> void:
	
	if !alive:
		return
	
	# add animation
	if velocity.x > 1 or velocity.x < -1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"
	
	# Add the gravity.
	if not is_on_floor() and not can_climb:
		velocity += get_gravity() * delta
		if velocity.x > 1 or velocity.x < -1:
			animated_sprite_2d.animation = "jumpRunning"
		else:
			animated_sprite_2d.animation = "jumpFront"
	if can_move:
		# Handle climbing
		if Input.is_action_pressed("climb") and can_climb:
			velocity.y = CLIMBING_SPEED
			climbing = true
			animated_sprite_2d.animation = "climbing"
			
		## Handle descending
		if Input.is_action_pressed("descend") and can_climb:
			velocity.y = DESCENDING_SPEED
			climbing = true
			animated_sprite_2d.animation = "climbing"

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and not can_climb:
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()

		if direction == 1.0:
			animated_sprite_2d.flip_h = false
		elif direction == -1.0:
			animated_sprite_2d.flip_h = true
		
func die() -> void:
	death_sound.play()
	animated_sprite_2d.animation = "hitFront"
	alive = false


func enable_climbing() -> void:
	can_climb = true

func disable_climbing() -> void:
	can_climb = false
	climbing = false
