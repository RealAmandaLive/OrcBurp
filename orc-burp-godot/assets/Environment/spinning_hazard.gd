extends Node2D

@export var spin_degrees_per_second = 90.0
@export var sound_angle_start_deg = 310
@onready var sound: AudioStreamPlayer2D = $SpinSound


func _process(delta: float) -> void:
	rotation += deg_to_rad(spin_degrees_per_second) * delta
	if sound !=null and rotation > deg_to_rad(sound_angle_start_deg):
		rotation -= PI * 2 # resets count without affecting visual angle
		sound.play()
