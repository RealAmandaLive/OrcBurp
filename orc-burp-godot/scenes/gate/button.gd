class_name TriggerButton
extends Area2D

signal triggered
signal rearmed

## If this is is set to zero, the button will never re-arm
@export var rearm_seconds: float = 1.0
## Is the button currently in the triggered state?
@export var is_triggered: bool = false
## If the player steps on the button while it's triggered, does it rearm?
@export var can_toggle: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D

var starting_region: Rect2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	starting_region = sprite_2d.region_rect

func _on_body_entered(_body) -> void:
	if not is_triggered:
		is_triggered = true
		_update_sprite()
		triggered.emit()
		if rearm_seconds > 0.0:
			get_tree().create_timer(rearm_seconds).timeout.connect(_rearm)
	elif can_toggle:
		_rearm()

func _rearm() -> void:
	if is_triggered: # its possible this could be called a few times if the button is toggleable
		is_triggered = false
		_update_sprite()
		rearmed.emit()

func _update_sprite() -> void:
	if is_triggered:
		sprite_2d.region_rect = Rect2(starting_region)
		sprite_2d.region_rect.size.y = starting_region.size.y / 2.0
		sprite_2d.offset.y = starting_region.size.y - sprite_2d.region_rect.size.y
	else:
		sprite_2d.region_rect = Rect2(starting_region)
		sprite_2d.offset.y = 0.0
