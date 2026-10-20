extends Area2D

@export var speed : float = 100

var direction : float = -1.0

@onready var timer: Timer = $Timer
@onready var shockwave_effect: ColorRect = $ShockwaveEffect

func p(args): print_rich("[bgcolor=yellow][color=black]Burp : ", args)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	global_position.x += delta * speed * direction


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		if body.has_method("apply_knockback"):
			body.apply_knockback()
		else:
			var message = " hit " + str(body) + " but it does not have a knockback method "
			p(message)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		if area.has_method("apply_knockback"):
			area.apply_knockback()
		else:
			var message = " hit " + str(area) + " but it does not have a knockback method "
			p(message)


func _on_timer_timeout() -> void:
	queue_free()
