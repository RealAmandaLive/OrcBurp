class_name Trap extends Area2D 

signal triggered(by_body: Node)

const SCANNED_MASK_LAYERS: int = 6 ## bitmask layers 2 and 3 (Player, Enemies)
const TRAPPABLE_META: StringName = &"trappable"
const TRAP_TIME: float = 2.5

@export var lifetime: float = 5.0

@export var sprite: Sprite2D ## for animations
@export var number_of_sprite_frames: int = 0
@export var framerate: float = 6.0

@export var offset_when_stuck_on_head: Vector2

var animation: Tween
var stuck_to_node: Node2D
var _lifetime: Tween

func _ready() -> void:
	collision_mask = SCANNED_MASK_LAYERS ## enforced
	
	_lifetime = create_tween()
	_lifetime.tween_interval(lifetime)
	_lifetime.tween_callback(queue_free)

func _process(_delta: float) -> void:
	if stuck_to_node:
		global_position = stuck_to_node.global_position + offset_when_stuck_on_head

func _physics_process(_delta: float) -> void:
	if not stuck_to_node:
		if not get_overlapping_bodies().is_empty():
			stick_to(get_overlapping_bodies().front())
		elif not get_overlapping_areas().is_empty():
			stick_to(get_overlapping_areas().front())

func stick_to(collider: Node) -> void:
	if is_queued_for_deletion():
		return
	
	if collider is Player:
		## foo
		print("Trap triggered by a Player")
		trap_physics_body(collider)
	
	elif collider.get_meta(TRAPPABLE_META, false):
		## Trappable enemies
		print("Trap triggered by an Enemy")
		trap_physics_body(collider)
	
	else:
		return
	
	animate()
	_lifetime.kill()
	stuck_to_node = collider
	triggered.emit(collider)
	

func trap_physics_body(collider: CollisionObject2D) -> void:
	var original_process_mode = collider.process_mode
	if original_process_mode == Node.PROCESS_MODE_DISABLED:
		return
	
	collider.process_mode = Node.PROCESS_MODE_DISABLED
	
	var t: Tween = collider.create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_interval(TRAP_TIME)
	t.tween_property(collider, ^"process_mode", original_process_mode, 0.0)
	t.tween_callback(queue_free)


func animate() -> void:
	if not sprite:
		return
	if not number_of_sprite_frames > 1:
		return
	
	stop_animation()
	animation = sprite.create_tween()
	animation.tween_property(
		sprite,
		^"frame",
		number_of_sprite_frames - 1,
		(1.0 / framerate) * number_of_sprite_frames
		).from(0)
	animation.set_loops()

func stop_animation() -> void:
	if animation:
		if animation.is_running():
			animation.kill()
