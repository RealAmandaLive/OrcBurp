# used by tiny coins and gems
# this one just gives points (gold)
# (not an inventory item)

extends Node2D

@export var gold_amount = 1
@export var pickup_distance = 8.0
@export var magnet_delay = 2.0
@export var magnet_distance = 320.0
@export var magnet_power = 600.0

var age = 0.0
var gut : Node2D

func _ready() -> void:
	print("mini loot "+name+" spawned at "+str(int(position.x))+","+str(int(position.y)))

func _process(delta: float) -> void:

	if not %Gut: 
		print("mini loot can't find the player node!")
		return # make sure player exists

	age += delta
	var dist = %Gut.global_position.distance_to($RigidBody2D.global_position)
	print("loot age: "+str(int(age))+" dist:"+str(int(dist)))
	
	if age >= magnet_delay:
		if dist <= magnet_distance:
			print("pulling loot towards the player!")
			$RigidBody2D.freeze = true # turn off physics so we can move it around manually
			$RigidBody2D.global_position = $RigidBody2D.global_position.move_toward(%Gut.global_position, (1.0-dist/magnet_distance)*magnet_power*delta)
			
	
	if dist <= pickup_distance:
		print("mini loot picked up!")
		Main.data.inc("goldCount",gold_amount)
		queue_free()
