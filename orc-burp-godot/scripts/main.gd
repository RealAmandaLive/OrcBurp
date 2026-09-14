extends Node2D
@onready var apple_label: Label = $HUD/ApplesCollected/appleLabel
@onready var fade: ColorRect = $HUD/fade


var level: int = 1
var applesCollected: int = 0
var current_level_root: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#setup level
	fade.modulate.a = 1.0
	current_level_root = get_node("levelRoot")
	await _load_level(level, true)


#--------
# LEVEL MANAGE
#-------------

func _load_level(level_number: int, first_load: bool) -> void:
	#fadeout
	if not first_load:
		await _fade(1.0)
	
	if current_level_root:
		current_level_root.queue_free()
		
	#changes level
	var level_path = "res://scenes/level%s.tscn" % level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "levelRoot"
	_setup_level(current_level_root)
	#fade in
	await _fade(0.0)

func _setup_level(level_root: Node) -> void:
	#connect exit
	var exit = level_root.get_node_or_null("exit")
	if exit:
		exit.body_entered.connect(_on_exit_body_entered)
	
	#connect apples
	var apples = level_root.get_node_or_null("Apples")
	if apples: 
		for apple in apples.get_children():
			apple.collected.connect(increase_applesCollected)
			
	#connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies: 
		for enemy in enemies.get_children():
			enemy.gut_died.connect(_on_gut_died)
			
			
# ---------
# SIGNAL HANDLERS
# ---------
func _on_gut_died(body):
	body.die()
	await _load_level(level, false)
	
func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Gut":
		level += 1
		body.can_move = false
		await _load_level(level, false)
	
# --------
# COLLECTING
# --------
func increase_applesCollected() -> void:
	applesCollected += 1
	apple_label.text = "Apples Collected: %s" % applesCollected
	
#------
# FADE
#------

func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished
