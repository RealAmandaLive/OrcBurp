extends Sprite2D

var speed = 4.0
var age = 0.0

# also fling upwards into air when spawned!!
var fling_strength: float = 600.0
var spin_strength: float = 1200.0

func _process(delta: float) -> void:
	age += delta
	scale.x = sin(age*speed) 

		# multiply scale by 2 because sprite is 2x pixel size
	scale.x *= 2
	
	# force a little thickness?
	# if scale.x < 0.25 and scale.x > -0.25: scale.x = 0.25
	
	# print("coin scale is "+str(scale.x))
