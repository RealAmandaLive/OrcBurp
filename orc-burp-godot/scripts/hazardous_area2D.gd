extends Area2D

@export var damageToPlayer = 1
@export var bumpPower = 400
@export var bumpExtraUp = -800 # completely unrealistic non physics nudge
@export var spawnWhenTouched: PackedScene
@onready var soundWhenTouched = $triggerSound

func _ready():
	print("ready to do some damage!")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	print("SOMETHING TOUCHED A HAZARD...")
	if body is Player:
		print("PLAYER TOUCHED A HAZARD!")
		# nudge to the side just a little, for feedback/juice
		# note: if it's too powerful, you to exit the trigger and get hit again and again
		body.get_bumped(Vector2(body.position.x - global_position.x, bumpExtraUp).normalized() * bumpPower)
		if soundWhenTouched: 
			soundWhenTouched.play()
		if spawnWhenTouched: 
			var boom = spawnWhenTouched.instantiate()
			# halfway between the area2d and player pivots:
			var midpoint = global_position.lerp(body.position, 0.5)
			boom.position = midpoint
			add_child(boom)
		body.take_damage(damageToPlayer)
