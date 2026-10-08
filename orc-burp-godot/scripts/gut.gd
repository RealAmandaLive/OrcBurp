class_name Player
extends CharacterBody2D

signal died
signal collected_apple

enum PlayerStates{IDLE, WALKING, JUMPING, CLIMBING, ON_LADDER}

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
const CLIMBING_SPEED = -300
const DESCENDING_SPEED = 400
const STARTING_HEALTH: int = 1 ## change me! TODO persistent state between level changes
const MAX_HEALTH: int = 3 ## change me!

var player_state = PlayerStates.IDLE: set = _set_state
var alive = true
var can_move = true
var can_climb = false
var climbing = false
var was_on_floor_last_frame = false # to detect landings

var health: int = STARTING_HEALTH

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
@onready var landingFX: CPUParticles2D = $LandingFX
@onready var landingSound: AudioStreamPlayer2D = $LandingSound
@onready var jumpingSound: AudioStreamPlayer2D = $JumpingSound
@onready var walkingSound: AudioStreamPlayer2D = $WalkingSound

func p(args): print_rich("[bgcolor=green][color=black]Player : ", args)

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
	
	var is_on_floor_now = is_on_floor()
	
	## JUMPING
	if Input.is_action_just_pressed("jump") and is_on_floor_now:
		jumpingSound.play()
		velocity.y = JUMP_VELOCITY
		
	## LANDING
	if not was_on_floor_last_frame and is_on_floor_now:
		landingSound.play()
		landingFX.restart()

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

	## FOOTSTEPS
	if player_state == PlayerStates.WALKING and is_on_floor_now:
		if not walkingSound.playing: # don't play too often
			walkingSound.play() # uses random pitch variation

	## GRAVITY
	if not can_climb:
		velocity += get_gravity() * delta
	elif can_climb and not climbing:
		velocity.y = 0
		player_state = PlayerStates.ON_LADDER

	move_and_slide()
	
	was_on_floor_last_frame = is_on_floor_now


func _set_state(state: PlayerStates) -> void:
	player_state = state
	
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
	


func take_damage(amount: int) -> void:
	if not alive: return
	
	health = maxi(0, health-amount)
	p("took %d damage, new health is %d." % [amount, health])
	if health == 0:
		die()

func collect_apple(health_increased: int) -> void:
	health = mini(MAX_HEALTH, health + health_increased)
	collected_apple.emit()
	p("collected an apple for %d health; new current health is %d." % [health_increased, health])

func die() -> void:
	if not alive: return
	
	death_sound.play()
	animated_sprite_2d.animation = "hitFront"
	alive = false
	died.emit()
	p("died.")
	

func enable_climbing() -> void:
	can_climb = true

func disable_climbing() -> void:
	can_climb = false
	climbing = false
