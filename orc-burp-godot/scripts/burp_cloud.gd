extends Area2D

@export var speed : float = 100

var direction : float = -1.0

@onready var timer: Timer = $Timer
@onready var shockwave_effect: ColorRect = $ShockwaveEffect


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)


func _physics_process(delta: float) -> void:
	global_position.x += delta * speed * direction


func _on_body_entered(body: Node2D) -> void:
	print("Burp cloud hit: ", body)


func _on_timer_timeout() -> void:
	queue_free()
