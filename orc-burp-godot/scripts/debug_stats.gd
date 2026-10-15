extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var player = get_tree().get_first_node_in_group(Main.PLAYER_GROUP)
	if not player: return
	text = "Debug: %d burps, %d toots, %d jumps, %d doubles, %d traps, %d deaths" % [player.burpCount,player.tootCount,player.jumpCount,player.doubleJumpCount,player.trapCount,player.deathCount]
	
	pass
