class_name HealthGUI
extends CanvasLayer

var player: Player

const HEART_SIZE: int = 1
const HEART_FULL = preload("res://assets/HUD/heartGUI/fullHeart.png")
const HEART_HALF = preload("res://assets/HUD/heartGUI/halfHeart.png")
const HEART_EMPTY = preload("res://assets/HUD/heartGUI/emptyHeart.png")

@onready var heart_container: HBoxContainer = $heartContainer

func set_player(p: Player) -> void:
	player = p
	p.health_changed.connect(_update_health)
	_update_health(Main.data.playerHealth)

func _update_health(new_health: int) -> void:
	var hearts = heart_container.get_children()
	var max_hearts = len(hearts)
	var full = int(new_health / HEART_SIZE)
	var half = 1 if (new_health % HEART_SIZE) > 0 else 0
	var empty = max_hearts - (full + half)

	for i in full:
		hearts[i].texture = HEART_FULL
	if half:
		hearts[full].texture = HEART_HALF
	## EMPTY HEARTS
	for i in empty:
		hearts[len(hearts) - 1 - i].texture = HEART_EMPTY
