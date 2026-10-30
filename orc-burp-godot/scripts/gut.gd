class_name Player
extends CharacterBody2D

signal died

enum PlayerStates{IDLE, WALKING, JUMPING, CLIMBING, ON_LADDER, DOUBLEJUMPING, TOOTING, BURPING}

const SPEED = 300.0
const JUMP_VELOCITY = -850.0
const CLIMBING_SPEED = -300
const DESCENDING_SPEED = 400

const BURP_CLOUD = preload("uid://pk1n1jjrqdji")

@export var speed_boost := 200

var player_state = PlayerStates.IDLE: set = _set_state
var alive = true
var can_move = true
var can_climb = false
var climbing = false
var was_on_floor_last_frame = false # to detect landings
var can_throw_traps: bool = true
var can_double_jump = true
var can_toot = true
var can_burp = true

var current_speed_boost := 0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var landingFX: CPUParticles2D = $LandingFX
@onready var landingSound: AudioStreamPlayer2D = $LandingSound
@onready var jumpingSound: AudioStreamPlayer2D = $JumpingSound
@onready var walkingSound: AudioStreamPlayer2D = $WalkingSound
@onready var tootSounds: AudioStreamPlayer2D = $TootSounds
@onready var burpSounds: AudioStreamPlayer2D = $BurpSounds
@onready var eatAppleSound: AudioStreamPlayer2D = $EatAppleSound


func p(args): print_rich("[bgcolor=green][color=black]Player : ", args)


func _ready() -> void:
	%TootTimer.timeout.connect(_on_toot_timer_timeout)
	%BurpTimer.timeout.connect(_on_burp_timer_timeout)
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_released(&"throw") and can_throw_traps:
		throw_trap()

func _physics_process(delta: float) -> void:
	if !alive:
		return
	
	## DIRECTION
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * (SPEED + current_speed_boost)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if signf(direction) == 1.0:
		animated_sprite_2d.flip_h = false
	elif signf(direction) == -1.0:
		animated_sprite_2d.flip_h = true
	
	var is_on_floor_now = is_on_floor()
	
	## JUMPING
	if Input.is_action_just_pressed("jump") and is_on_floor_now:
		Main.data.inc("jumpCount")
		jumpingSound.play()
		velocity.y = JUMP_VELOCITY
	
	## DOUBLE JUMP
	if Input.is_action_just_pressed("jump") and not is_on_floor_now and can_double_jump and not climbing:
		Main.data.inc("doubleJumpCount")
		jumpingSound.play()
		velocity.y = JUMP_VELOCITY
		can_double_jump = false
		player_state = PlayerStates.DOUBLEJUMPING
		
	## LANDING
	if not was_on_floor_last_frame and is_on_floor_now:
		landingSound.play()
		landingFX.restart()
		can_double_jump = true

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
	if player_state == PlayerStates.TOOTING or player_state == PlayerStates.BURPING:
		pass
	elif velocity == Vector2.ZERO:
		player_state = PlayerStates.IDLE
	elif velocity.x != 0 and velocity.y == 0:
		player_state = PlayerStates.WALKING
	elif velocity.y != 0 and not climbing: 
		player_state = PlayerStates.JUMPING
	elif velocity.y != 0 and can_double_jump: 
		player_state = PlayerStates.DOUBLEJUMPING
	elif velocity.y != 0 and climbing:
		player_state = PlayerStates.CLIMBING

	## FOOTSTEPS
	if player_state == PlayerStates.WALKING and is_on_floor_now:
		if not walkingSound.playing: # don't play too often
			walkingSound.play() # uses random pitch variation
			
	## TOOTS
	if Input.is_action_just_pressed("toot") and can_toot:
		toot()

	## BURPS
	if Input.is_action_just_pressed("burp") and can_burp:
		burp(direction)

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
			#animated_sprite_2d.animation = "idle"
			%AnimatedSprite2D.play("idle")
			can_throw_traps = true
		PlayerStates.WALKING:
			%AnimatedSprite2D.play("running")
			can_throw_traps = true
		PlayerStates.JUMPING:
			if velocity.x > 1 or velocity.x < -1:
				%AnimatedSprite2D.play("jumpRunning")
			else:
				%AnimatedSprite2D.play("jumpFront")
			can_throw_traps = true
		PlayerStates.CLIMBING:
			%AnimatedSprite2D.play("climbing")
			can_throw_traps = false
		PlayerStates.ON_LADDER:
			%AnimatedSprite2D.play('onLadder')
			can_throw_traps = false
		PlayerStates.DOUBLEJUMPING:
			if velocity.x > 1 or velocity.x < -1:
				%AnimatedSprite2D.play("jumpRunning")
			else:
				%AnimatedSprite2D.play("jumpFront")
				can_throw_traps = true
		PlayerStates.TOOTING:
			%AnimatedSprite2D.play("tooting")
		PlayerStates.BURPING:
			%AnimatedSprite2D.play("burping")

# called by hazardous_area2d swinging chains etc
func get_bumped(amountVector) -> void:
	print("player got bumped")
	velocity += amountVector

func take_damage(amount: int) -> void:
	if not alive: return
	
	Main.data.playerHealth -= amount
	p("took %d damage, new health is %d." % [amount, Main.data.playerHealth])
	if Main.data.playerHealth == 0:
		die()

func collect_apple(health_increased: int) -> void:
	Main.data.playerHealth += health_increased
	Main.data.inc("applesCollected")
	p("collected an apple for %d health; new current health is %d." % [health_increased, Main.data.playerHealth])
	eatAppleSound.play()


func throw_trap() -> void:
	const THROW_IMPULSE_VELOCITY: float = 768.0 ## pixels per second
	const THROWN_COLLISION_RADIUS: float = 16.0 ## pixels; we could also just get this from the sprite...
	
	var node_to_parent_trap: Node = Main.get_instance().current_level_root
	
	## Make a physics object to throw in that direction, which will carry the trap.
	var trap_physics := RigidBody2D.new()
	var collider := CollisionShape2D.new();  var shape := CircleShape2D.new()
	collider.shape = shape;  shape.radius = THROWN_COLLISION_RADIUS
	trap_physics.add_child(collider)
	
	## Don't roll around
	trap_physics.lock_rotation = true
	
	## Set the collision mask to only collide with the walls and floor.
	## -- See "res://assets/ tile_set.tres "
	trap_physics.set_collision_mask_value(1, false)
	trap_physics.set_collision_mask_value(5, true)
	
	trap_physics.set_collision_layer_value(1, false)
	
	## Contact monitoring to stop the physics upon landing.
	trap_physics.contact_monitor = true
	trap_physics.max_contacts_reported = 2
	
	## Make the Trap object itself which has the logic for hurting enemies or the player.
	#var trap := Trap.new()
	var trap = preload("uid://0iaf024fbyk8").instantiate() ## HACK TESTING
	trap_physics.add_child(trap)
	
	## Lambda function to remove physics behavior but retain the Trap node.
	var reparent_trap: Callable = func():
		trap.reparent(node_to_parent_trap)
		if trap_physics:
			trap_physics.queue_free()
		print("Reparented trap")
	
	## When the trap is triggered, remove the physics behavior.
	trap.triggered.connect(reparent_trap.unbind(1))
	
	## When the physics object has collision with ground/wall,
	## preserve the Trap itself by reparenting it, and remove physics behavior.
	trap_physics.body_entered.connect(reparent_trap.unbind(1))
	
	
	var throw_direction: float = 1.0 ## HACK TESTING
	var starting_position: Vector2 = Vector2(THROWN_COLLISION_RADIUS * throw_direction * 2.5, 0.0) ## HACK TESTING
	var impulse: Vector2 = Vector2(THROW_IMPULSE_VELOCITY * throw_direction, 0.0).rotated(-PI/4) ## HACK TESTING
	
	trap_physics.global_position = self.global_position + starting_position
	node_to_parent_trap.add_child(trap_physics)
	trap_physics.apply_central_impulse(impulse)
	Main.data.inc("trapCount")


## Return a target within a bounding box using the current facing direction.
## If no target is found, returns [Vector2.ZERO].
func find_throw_target(distance: float) -> Vector2:
	var current_facing_direction: float = signf(velocity.x)
	
	return Vector2.ZERO


func die() -> void:
	if not alive: return
	Main.data.inc("deathCount")
	AudioManager.play_death_sound("fall")
	animated_sprite_2d.animation = "hitFront"
	alive = false
	died.emit()
	p("died.")
	

func enable_climbing() -> void:
	can_climb = true

func disable_climbing() -> void:
	can_climb = false
	climbing = false


func toot() -> void:
	## todo: spawn particles, check hitboxes, etc maybe in their own scene we instantiate
	## for now this just plays a random toot sound from a pool
	can_toot = false
	%TootTimer.start()
	player_state = PlayerStates.TOOTING
	current_speed_boost = speed_boost
	Main.data.inc("tootCount")
	await get_tree().create_timer(0.5).timeout
	tootSounds.play()


func _on_toot_timer_timeout() -> void:
	can_toot = true
	current_speed_boost = 0


func burp(direction: float) -> void:
	## todo: implement gameplay as above
	can_burp = false
	%BurpTimer.start()
	player_state = PlayerStates.BURPING
	Main.data.inc("burpCount")
	await get_tree().create_timer(0.2).timeout
	burpSounds.play()
	var burp_instance = BURP_CLOUD.instantiate()
	burp_instance.global_position = global_position
	add_sibling(burp_instance)
	if signf(direction) >= 0.0:
		burp_instance.rotation = PI
		burp_instance.direction = 1.0


func _on_burp_timer_timeout() -> void:
	can_burp = true


func _on_animation_finished() -> void:
	if player_state == PlayerStates.TOOTING or player_state == PlayerStates.BURPING:
		player_state = PlayerStates.IDLE
