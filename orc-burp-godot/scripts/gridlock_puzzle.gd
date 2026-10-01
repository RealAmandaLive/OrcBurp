class_name GridLockPuzzle
extends Node2D

var active := true

@onready var win_sound: AudioStreamPlayer2D = $Winning/WinSound
@onready var animation_player: AnimationPlayer = $Winning/AnimationPlayer


func _on_puzzle_complete(piece: Node2D) -> void:
	if piece is GridLockPiece:
		active = false
		win_sound.play()
		animation_player.play("win")
