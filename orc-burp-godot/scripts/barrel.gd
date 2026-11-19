extends Area2D

@export var spawn_when_opened1: PackedScene
@export var spawn_when_opened2: PackedScene
@export var spawn_when_opened3: PackedScene

var currentlyOpen = false

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
		call_deferred("spawn_loot")	
		
		# destroy self but wait for enough time to play the sound in full
		await get_tree().create_timer(2.0).timeout
		queue_free()

func spawn_loot() -> void:
		# spawn up to three things (particles, loot, pickups, etc)
		if spawn_when_opened1: 
			var loot1 = spawn_when_opened1.instantiate()
			loot1.position = position
			get_parent().add_child(loot1)
		if spawn_when_opened2: 
			var loot2 = spawn_when_opened2.instantiate()
			loot2.position = position
			get_parent().add_child(loot2)
		if spawn_when_opened3: 
			var loot3 = spawn_when_opened3.instantiate()
			loot3.position = position
			get_parent().add_child(loot3)
	
