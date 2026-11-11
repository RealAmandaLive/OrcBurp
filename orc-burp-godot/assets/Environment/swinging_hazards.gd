extends Node2D

@export var swing_left_degrees = 80.0
@export var swing_left_seconds = 1.5
@export var swing_right_degrees = -80.0
@export var swing_right_seconds = 1.5
@export var start_phase_offset = 0.25
@export var sound_start_delay_sec = 0.75


func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(start_phase_offset) # shifts start so they aren't synchronized
	tween.tween_callback(main_swinging)
	tween.tween_interval(sound_start_delay_sec) # lets sounds play partway into each swing
	tween.tween_callback(sound_swinging)
	
func main_swinging() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation", deg_to_rad(swing_left_degrees), swing_left_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(swing_right_degrees), swing_right_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
func sound_swinging() -> void:
		var tween_sound = create_tween().set_loops()
		tween_sound.tween_callback(sound_play)
		tween_sound.tween_interval(swing_left_seconds)
		tween_sound.tween_callback(sound_play)
		tween_sound.tween_interval(swing_right_seconds)
		
func sound_play() -> void:
		# the below can be handy for debugging relative sing timers but
		#comment it out before committing to repo since it floods the output
		#print("sound playing now:", (Time.get_ticks_msec()/1000.0))
		$SpinSound2.play() 
	
		
	
