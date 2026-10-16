extends Label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group(Main.PLAYER_GROUP)
	if not player: return
	text = "Debug: %d burps, %d toots, %d jumps, %d doubles, %d traps, %d deaths" % [
		Main.data.burpCount,
		Main.data.tootCount,
		Main.data.jumpCount,
		Main.data.doubleJumpCount,
		Main.data.trapCount,
		Main.data.deathCount,
	]
