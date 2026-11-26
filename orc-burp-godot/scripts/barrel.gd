extends Area2D

@export var loot_config:LootTable

@onready var _loot_spawner: LootSpawner = $LootSpawner

var currentlyOpen = false

func _enter_tree() -> void:
	# Assign in enter tree so it is valid when ready is called
	# Cannot refer to @onready variable as it is set in ready which is too late since child ready already fired
	$LootSpawner.config = loot_config
	
func _on_body_entered(body: Node2D) -> void:
		
		if currentlyOpen: return # can only be opened once
		
		# TODO: maybe we should check that this truly is the player
		# however this area2d has a collision mask of 2 (player only)
		print(body.name+" is opening a treasure chest!")
		currentlyOpen = true
		
		# play a sound effect
		if $openSound: $openSound.play()
		
		# make chest vanish but wait around while we play the sound
		if $Sprite2D: $Sprite2D.hide()
	
		# spawn stuff outside this event to prevent errors
		_loot_spawner.spawn.call_deferred(position, get_parent())
		
		# destroy self but wait for enough time to play the sound in full
		await get_tree().create_timer(2.0).timeout
		queue_free()
	
