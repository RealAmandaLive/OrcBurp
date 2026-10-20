class_name LevelExit
extends Area2D

signal player_entered(next_level: String)

@export_file_path("*.tscn") var target_level: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body) -> void:
	if body.name == "Gut":
		player_entered.emit.call_deferred(target_level)
		Main.get_instance().load_level.call_deferred(target_level, false)
