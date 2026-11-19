# used by tiny coins and gems
# this one just gives points (gold)
# (not an inventory item)

extends Node2D

@export var gold_amount:int = 1
@export var pickup_distance:float = 8.0
@export var magnet_delay:float = 1.0
@export var magnet_distance:float = 320.0
@export var magnet_power:float = 600.0

var age:float = 0.0
var gut : Node2D
var myRB : RigidBody2D
var thePlayer : Node2D
var pickupSound: AudioStreamPlayer2D

func _ready() -> void:
	# print("mini loot "+name+" spawned at "+str(int(position.x))+","+str(int(position.y)))
	myRB = $RigidBody2D
	pickupSound = $pickupSound

func _process(delta: float) -> void:

	if thePlayer == null: 
		thePlayer = get_tree().root.find_child("Gut", true, false)
	
	if not thePlayer: #this should always be true?! hmmm.....
		print("mini loot can't find the player node!")
		return # make sure player exists

	age += delta
	var dist = thePlayer.global_position.distance_to(myRB.global_position)
	# print("loot age: "+str(int(age))+" dist:"+str(int(dist)))
	
	if age >= magnet_delay:
		if dist <= magnet_distance:
			# print("pulling loot towards the player!")
			myRB.freeze = true # turn off physics so we can move it around manually
			myRB.global_position = myRB.global_position.move_toward(thePlayer.global_position, (1.0-dist/magnet_distance)*magnet_power*delta)
			
	if dist <= pickup_distance:
		# print("mini loot picked up!")
		thePlayer.collect_coin(gold_amount)
		myRB.queue_free() 
		queue_free()
