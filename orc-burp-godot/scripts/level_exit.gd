class_name LevelExit
extends Area2D

signal player_entered(next_level: String)

@export_file_path("*.tscn") var target_level: String

@export var fade_color := Color.BLACK
@export var requires_key := false
@export var light_switch := false

## If this is set or if there's a child node called "Label" the
## player will not enter automatically but will have to
## press the interact button
@export var label: Label

var original_text: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not label:
		label = get_node_or_null("Label")
	if label:
		label.hide()
		original_text = label.text

func _can_open() -> bool:
	return (
		not requires_key 
		or Main.data.has_unlocked_door(self)
		or Main.data.get_key_count() > 0
	)

func _on_body_entered(body) -> void:
	if body.name == "Gut":
		if label:
			label.show()
			if _can_open():
				label.text = original_text
			else:
				label.text = "This door is locked."
		else:
			_travel_to_target()

func _input(event: InputEvent) -> void:
	if label and _can_open() and label.visible and (
		event.is_action_pressed("interact")
		or event.is_action_pressed("climb")
		or event.is_action_pressed("descend")
	):
		_travel_to_target()

func _on_body_exited(body) -> void:
	if body.name == "Gut" and label:
		label.hide()


func _travel_to_target() -> void:
	if light_switch:
		Main.data.record_lights_turned_on()
	if requires_key:
		Main.data.remove_item_from_inventory("key", 1)
		Main.data.record_unlocked_door(self)
	Main.data.record_location(Main.get_player().global_position)
	player_entered.emit.call_deferred(target_level)
	Main.get_instance().load_level.call_deferred(target_level, false, fade_color)
