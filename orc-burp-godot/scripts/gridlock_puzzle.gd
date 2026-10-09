class_name GridLockPuzzle
extends Node2D

signal completed

var active := true

@onready var win_sound: AudioStreamPlayer2D = $Winning/WinSound
@onready var animation_player: AnimationPlayer = $Winning/AnimationPlayer
@onready var background: ColorRect = $Background


func disable() -> void:
	active = false
	process_mode = Node.PROCESS_MODE_DISABLED


func enable() -> void:
	for n in get_tree().get_nodes_in_group("gridlock_pieces"):
		n.velocity = Vector2.ZERO
	active = true
	set_deferred("process_mode", Node.PROCESS_MODE_PAUSABLE)


func get_ideal_size() -> Vector2:
	return background.custom_minimum_size


func _on_puzzle_complete(piece: Node2D) -> void:
	if piece is GridLockPiece and piece.has_key:
		active = false
		win_sound.play()
		animation_player.play("win")
		var t = create_tween()
		t.tween_property(piece, "position", piece.position + Vector2(200.0, 0.0), 1.0)
		await animation_player.animation_finished
		completed.emit.call_deferred()
