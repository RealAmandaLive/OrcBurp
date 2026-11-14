class_name LevelExit
extends Area2D

signal player_entered(next_level: String)

@export_file_path("*.tscn") var target_level: String

## If this is set or if there's a child node called "Label" the
## player will not enter automatically but will have to
## press the interact button
@export var label: Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if not label:
		label = get_node_or_null("Label")
	if label:
		label.hide()

func _on_body_entered(body) -> void:
	if body.name == "Gut":
		if label:
			label.show()
		else:
			player_entered.emit.call_deferred(target_level)
			Main.get_instance().load_level.call_deferred(target_level, false)

func _input(event: InputEvent) -> void:
	if label and event.is_action_pressed("interact") and label.visible:
		player_entered.emit.call_deferred(target_level)
		Main.get_instance().load_level.call_deferred(target_level, false)

func _on_body_exited(body) -> void:
	if body.name == "Gut" and label:
		label.hide()
