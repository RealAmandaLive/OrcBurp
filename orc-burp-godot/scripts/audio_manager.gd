extends Node

const FALLING_SOUND = preload("res://assets/Audio/fall_3.wav")

func play_death_sound(death_cause: String) -> void:
	if death_cause == "fall":
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = FALLING_SOUND
		get_tree().root.add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(audio_player.queue_free)
