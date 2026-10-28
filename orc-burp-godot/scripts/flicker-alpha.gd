# this makes the glows around fire fx "flicker" smoothly

extends Sprite2D

var noise : FastNoiseLite = FastNoiseLite.new()
@export var enabled = false
@export var speed = 6.0
@export var freq = 0.5
@export var min_a = 0.1
@export var max_a = 1.0
var age = 0.0

func _ready() -> void:
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = freq
	noise.seed = randi()

func _process(delta: float) -> void:
	if !enabled: return
	age += delta * speed
	var wobble : float = (noise.get_noise_1d(age)+1)/2 # force 0..1 range
	var final_alpha : float = lerp(min_a, max_a, wobble) # fit in min/max
	self_modulate.a = final_alpha
