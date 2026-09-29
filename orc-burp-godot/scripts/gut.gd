class_name Player
extends CharacterBody2D

enum PlayerStates{IDLE, WALKING, JUMPING, CLIMBING, ON_LADDER}

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
const CLIMBING_SPEED = -300
const DESCENDING_SPEED = 400

var player_state = PlayerStates.IDLE
var alive = true
var can_move = true
var can_climb = false
var climbing = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

func _physics_process(delta: float) -> void:
	if !alive:
		return
	
	## DIRECTION
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if signf(direction) == 1.0:
		animated_sprite_2d.flip_h = false
	elif signf(direction) == -1.0:
		animated_sprite_2d.flip_h = true
	
	## JUMPING
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	## CLIMBING
	if Input.is_action_pressed("climb") and can_climb:
		velocity.y = CLIMBING_SPEED
		climbing = true
	if Input.is_action_pressed("descend") and can_climb:
		velocity.y = DESCENDING_SPEED
		climbing = true
	if Input.is_action_just_released("climb"):
		climbing = false
	if Input.is_action_just_released("descend"):
		climbing = false

	## STATE DETERMINATION
	if velocity == Vector2.ZERO:
		player_state = PlayerStates.IDLE
	elif velocity.x != 0 and velocity.y == 0:
		player_state = PlayerStates.WALKING
	elif velocity.y != 0 and not climbing: 
		player_state = PlayerStates.JUMPING
	elif velocity.y != 0 and climbing:
		player_state = PlayerStates.CLIMBING

	## GRAVITY
	if not can_climb:
		velocity += get_gravity() * delta
	elif can_climb and not climbing:
		velocity.y = 0
		player_state = PlayerStates.ON_LADDER

	move_and_slide()
	
	_animate_sprite()


func _animate_sprite() -> void:
		match player_state:
			PlayerStates.IDLE: 
				animated_sprite_2d.animation = "idle"
			PlayerStates.WALKING:
				animated_sprite_2d.animation = "running"
			PlayerStates.JUMPING:
				if velocity.x > 1 or velocity.x < -1:
					animated_sprite_2d.animation = "jumpRunning"
				else:
					animated_sprite_2d.animation = "jumpFront"
			PlayerStates.CLIMBING:
				animated_sprite_2d.animation = "climbing"
			PlayerStates.ON_LADDER:
				animated_sprite_2d.animation = 'onLadder'


func die() -> void:
	death_sound.play()
	animated_sprite_2d.animation = "hitFront"
	alive = false


func enable_climbing() -> void:
	can_climb = true

func disable_climbing() -> void:
	can_climb = false
	climbing = false
