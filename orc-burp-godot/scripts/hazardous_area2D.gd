
# note: not triggering?
# make sure the collision layers are set to notice the player (usually 2)

extends Area2D

@export var damageToPlayer = 1
@export var bumpPower = 400
@export var bumpExtraUp = -800 # completely unrealistic non physics nudge
@export var spawnWhenTouched: PackedScene
@onready var soundWhenTouched = $triggerSound
@onready var particleFX: CPUParticles2D = $triggerParticles

func _ready():
	#print("ready to do some damage!")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		#print("PLAYER TOUCHED A HAZARD!")
		
		# push the player to the side and up just a little, for feedback/juice
		# note: if it's the wrong strength, you might exit the trigger and get hit again the very next frame
		var sign = 1;
		if (global_position.x > body.position.x): sign = -1
		var bumpImpulse = Vector2(sign * bumpPower, bumpExtraUp)
		body.get_bumped(bumpImpulse)
			
		# old version: just a little hop
		# body.get_bumped(Vector2(0, bumpExtraUp).normalized() * bumpPower)
		
		# a little puff of dust
		if particleFX: particleFX.restart()
		
		if soundWhenTouched: 
			soundWhenTouched.play()
		
		if spawnWhenTouched: 
			var boom = spawnWhenTouched.instantiate()
			# halfway between the area2d and player pivots:
			var midpoint = global_position.lerp(body.position, 0.5)
			boom.position = midpoint
			add_child(boom)

		body.take_damage(damageToPlayer)
