class_name KnockbackApplier extends Node

@export
var knockback_multiplier:float = 1.0

@export
var knockback_time:float = 1.0

@export
var body:Node2D

var active:bool

var _time_rem:float
var _force:float

var direction:float:
	get:
		return signf(_force)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	assert(body)
	
func _process(delta: float) -> void:
	var dx:float = delta * _force
	body.position.x += dx
	
	_time_rem -= delta
	if _time_rem <= 0.0:
		stop()
		
func start(horizontal_force:float) -> void:
	_force = horizontal_force * knockback_multiplier
	print("knockback applied: force=%.1f" % _force)
	
	active = true
	_time_rem = knockback_time
	process_mode = Node.PROCESS_MODE_INHERIT

func stop() -> void:
	active = false
	_time_rem = 0.0
	process_mode = Node.PROCESS_MODE_DISABLED
