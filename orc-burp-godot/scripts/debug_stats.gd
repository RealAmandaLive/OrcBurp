extends Label

func _ready() -> void:
	Main.data.changed.connect(_on_data_changed)
	
func _on_data_changed() -> void:
	text = "Debug: %d burps, %d toots, %d jumps, %d doubles, %d traps, %d deaths" % [
		Main.data.burpCount,
		Main.data.tootCount,
		Main.data.jumpCount,
		Main.data.doubleJumpCount,
		Main.data.trapCount,
		Main.data.deathCount,
	]
