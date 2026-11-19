extends Node

const SHAKE_SPEED = 2.0
const STRENGTH_MULTIPLIER = 16.0 # convert 1.0 strength to pixels

# Intensity constants
const FREAK_OUT = 1.5
const QUAKE = 1.0
const TREMOR = 0.5

# Timing constants
const SHORT = 0.3
const MID = 0.7
const LONG = 1.0
const EXTENDED = 2.0

# Types of screen flash. See "flash" method below for details.
enum Flash { LIGHT, DARK }


@onready var noise := FastNoiseLite.new()
var shake_strength: float = 0.0
var shake_decay: float = 1.0
var flash_tween: Tween

# allows the user to turn down shaking
var shake_volume_setting := 1.0


func get_shake_volume() -> float:
	return shake_volume_setting


func set_shake_volume(value: float) -> void:
	shake_volume_setting = value


## Screen shake with optional controller shake
func shake(seconds: float = MID, intensity: float = QUAKE, controller_shake: bool = true) -> void:
	var new_strength = intensity * STRENGTH_MULTIPLIER * shake_volume_setting
	if new_strength <= shake_strength or seconds <= 0.0:
		return
	shake_strength = new_strength
	shake_decay = new_strength / seconds

	var weak_vibes := 0.0
	var strong_vibes := 0.0
	if intensity > TREMOR:
		strong_vibes = clampf((intensity - 0.5) * 2.0, 0.0, 1.0)
	else:
		weak_vibes = clampf(intensity * 2.0, 0.0, 1.0)
	if controller_shake:
		Input.start_joy_vibration(0, weak_vibes, strong_vibes, seconds)


## Screen flash
func flash(seconds: float = MID, intensity: float = QUAKE, type: Flash = Flash.LIGHT) -> Tween:
	var hud: HUD = get_tree().root.get_node_or_null("/root/main/HUD")
	if hud:
		var color = Color.WHITE if type == Flash.LIGHT else Color.BLACK
		color.a = intensity
		hud.set_fade_color(color)
		hud.force_screen_faded()
		return hud.fade_to(0.0, seconds)
	return null

var slomo_tween: Tween
func slomo(seconds = MID, intensity = QUAKE) -> Tween:
	Engine.time_scale = lerpf(1.0, 0.1, ease(intensity, 0.6))
	return tween_time_scale(1.0, seconds)


func tween_time_scale(value: float, seconds = MID) -> Tween:
	if slomo_tween and not slomo_tween.finished:
		slomo_tween.stop()
	slomo_tween = get_tree().create_tween()
	slomo_tween.set_ease(Tween.EASE_IN_OUT)
	slomo_tween.set_trans(Tween.TRANS_SINE)
	slomo_tween.tween_property(Engine, "time_scale", value, seconds)
	return slomo_tween



func _get_world_env() -> WorldEnvironment:
	return get_tree().get_first_node_in_group("world_environment")


func _get_fade_screen_rect() -> ColorRect:
	return get_tree().get_first_node_in_group("fade_screen")


func get_shake_offset(speed: float = SHAKE_SPEED, extra_offset: float = 0.0) -> Vector2:
		var noise_idx := float(Time.get_ticks_msec()) * speed + extra_offset
		return Vector2(
			noise.get_noise_2d(1.0, noise_idx),
			noise.get_noise_2d(100.0, noise_idx),
		)

func _process(delta: float) -> void:
	var cam = get_viewport().get_camera_2d()
	if not cam: return
	if shake_strength > 0.0:
		shake_strength = move_toward(shake_strength, 0.0, shake_decay * delta)
		cam.offset = get_shake_offset() * shake_strength


# This is just for testing. We should remove it before release
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and not event.is_echo():
		#match event.physical_keycode:
			#KEY_4:
				#shake(LONG, QUAKE)
			#KEY_3:
				#shake(SHORT, TREMOR)
			#KEY_5:
				#flash(SHORT, TREMOR, Flash.LIGHT)
			#KEY_6:
				#flash(SHORT, TREMOR, Flash.DARK)
			#KEY_7:
				#slomo(SHORT, QUAKE)
