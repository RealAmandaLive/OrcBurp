extends Node2D

@export var swing_left_degrees = 90.0
@export var swing_left_seconds = 1.5
@export var swing_right_degrees = -90.0
@export var swing_right_seconds = 1.5

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(self, "rotation", deg_to_rad(swing_left_degrees), swing_left_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation", deg_to_rad(swing_right_degrees), swing_right_seconds).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
