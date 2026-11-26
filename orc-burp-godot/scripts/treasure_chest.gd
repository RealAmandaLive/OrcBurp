extends Area2D

@export var loot_config:LootTable

@onready var _loot_spawner: LootSpawner = $LootSpawner

var currentlyOpen = false

		
func _enter_tree() -> void:
	# Assign in enter tree so it is valid when ready is called
	# Cannot refer to @onready variable as it is set in ready which is too late since child ready already fired
	$LootSpawner.config = loot_config
	
func _ready() -> void:
	if Main.data.is_item_taken(self):
		currentlyOpen = true
		_open_chest()

func _on_body_entered(body: Node2D) -> void:
		
		if currentlyOpen: return # can only be opened once
		
		# TODO: maybe we should check that this truly is the player
		# however this area2d has a collision mask of 2 (player only)
		print(body.name+" is opening a treasure chest!")
		currentlyOpen = true
		
		# play a sound effect
		if $openSound: $openSound.play()
		
		_open_chest()
	
		# spawn stuff outside this event to prevent errors
		_loot_spawner.spawn.call_deferred(position, get_parent())
		
		Main.data.record_item_taken(self)

func _open_chest() -> void:
	# trigger the chest opening animation
	if $AnimatedSprite2D: $AnimatedSprite2D.play("open")
