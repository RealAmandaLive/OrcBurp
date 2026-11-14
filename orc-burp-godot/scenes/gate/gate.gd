class_name Gate
extends StaticBody2D

## the button or buttons that will open / close the door
@export var buttons: Array[TriggerButton]

## does it start open or closed?
@export var is_open: bool = false

## should the door close again when the button rearms?
@export var autoclose: bool = false

## How far and in what direction should the gate move from the starting position when open?
@export var open_offset: Vector2 = Vector2(0, -128)

## How long should the gate take to move when opening and closing?
@export var tween_seconds: float = 0.5

var tween: Tween
var starting_pos: Vector2

func _ready() -> void:
	for b in buttons:
		b.triggered.connect(_on_button_trigger)
		b.rearmed.connect(_on_button_rearm)
	starting_pos = position

func _on_button_trigger() -> void:
	if not is_open:
		is_open = true
		open()
	
func _on_button_rearm() -> void:
	if is_open and autoclose:
		is_open = false
		close()

func open() -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", starting_pos + open_offset, tween_seconds)

func close() -> void:
	if tween and tween.is_running():
		tween.stop()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", starting_pos, tween_seconds)
