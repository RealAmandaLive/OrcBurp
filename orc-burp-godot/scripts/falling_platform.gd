extends AnimatableBody2D

@export var shake_duration: float = 2.0
@export var shake_magnitude: float = 1.0
@export var shake_speed: float = 0.4
@export var fall_speed: float = 300
@export var shake_noise: FastNoiseLite = FastNoiseLite.new()
@export var cancel_on_exit: bool = false

var is_triggered: bool = false
var is_falling: bool = false

var shake_timer: float = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var initial_sprite_pos: Vector2 = sprite.position
@onready var reappear_timer: Timer = $ReappearTimer

var initial_gpos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reappear_timer.timeout.connect(_on_reappear_timeout)
	initial_gpos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_falling:
		position.y += fall_speed * delta
	elif is_triggered and shake_timer > 0:
		shake_timer -= delta
		#sprite.position = initial_sprite_pos + VFX.get_shake_offset(shake_speed) * shake_magnitude * 2.0 * Vector2(0.5, 1.0)
		var offset := VFX.get_shake_offset(shake_speed, global_position.x)
		sprite.rotation = offset.x * shake_magnitude * 0.2
		sprite.position.y = initial_sprite_pos.y + offset.y * shake_magnitude * 2.0
		if shake_timer <= 0:
			sprite.position = initial_sprite_pos
			sprite.rotation = 0
			is_falling = true
			reappear_timer.start()
			#$CollisionShape2D.disabled = true

func _on_player_detection_zone_body_entered(body: Node2D) -> void:
	if body is Player and not is_triggered:
		is_triggered = true
		shake_timer = shake_duration

func _on_player_detection_zone_body_exited(body: Node2D) -> void:
	if body is Player and not is_falling and cancel_on_exit:
		is_triggered = false
		sprite.position = initial_sprite_pos
		sprite.rotation = 0

func _on_reappear_timeout() -> void:
	var t = create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_EXPO)
	t.tween_property(self, "global_position", initial_gpos, 1.0)
	is_falling = false
	is_triggered = false
