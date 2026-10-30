extends AnimatableBody2D

@export var shake_duration: float = 2
@export var shake_magnitude: float = 1
@export var fall_speed: float = 300

var is_triggered: bool = false
var is_falling: bool = false
var shake_timer: float = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var initial_sprite_pos: Vector2 = sprite.position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_falling:
		position.y += fall_speed * delta
	elif is_triggered and shake_timer > 0:
		shake_timer -= delta
		
		var offset_x = randf_range(-shake_magnitude, shake_magnitude)
		var offset_y = randf_range(-shake_magnitude, shake_magnitude)
		sprite.position = initial_sprite_pos + Vector2(offset_x, offset_y)
		if shake_timer <= 0:
			sprite.position = initial_sprite_pos
			is_falling = true
			#$CollisionShape2D.disabled = true

func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player and not is_triggered:
		is_triggered = true
		shake_timer = shake_duration
