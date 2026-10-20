class_name Main extends Node2D

const PLAYER_GROUP: StringName = &"Player"

static var instance: Main
static func get_instance() -> Main:
	assert(instance)
	return instance

static var data: GameData = GameData.new()

@export_file_path("*.tscn") var first_level: String

var current_level_name: String
var current_level_path: String
var current_level_root: Node = null
var is_changing_level: bool = false

@onready var hud: HUD = %HUD
@onready var health_gui: HealthGUI = %healthGUI

func p(args): print_rich("[bgcolor=white][color=black]Main : ", args)

func _enter_tree() -> void:
	assert(not instance)
	instance = self

func _exit_tree() -> void:
	assert(instance == self)
	instance = null


func _ready() -> void:
	#setup level
	hud.force_screen_faded()
	current_level_root = get_node("levelRoot")
	## NOTE we are loading the level twice here--levelRoot is a scene in Main with the level
	## then we run load level which discards it and loads it again.
	await load_level(first_level, true)


#--------
# LEVEL MANAGE
#-------------

## Loads a level and fires a signal when finished.
func load_level(level_path: String, first_load: bool) -> void:
	if is_changing_level:
		push_error("Load Level called while already changing levels.")
		return
	
	p("changing level...")
	is_changing_level = true
	set_player_frozen(true) ## freeze current scene Gut
	
	#fadeout
	if not first_load:
		await hud.fade_to(1.0).finished
	
	if current_level_root:
		p("freeing %s" % current_level_root)
		current_level_root.queue_free()
	
	await get_tree().process_frame ## Wait for the objects to be freed
	
	#changes level
	assert(FileAccess.file_exists(level_path), "Not a valid file path to load.")
	current_level_path = level_path
	current_level_name = level_path.get_file().get_basename()
	current_level_root = load(level_path).instantiate()
	p("loaded %s (%s)" % [level_path, current_level_name])
	
	add_child(current_level_root)
	current_level_root.name = "levelRoot"
	_setup_level(current_level_root)
	
	## Freeze our new scene's Gut
	## I'm leaving this commented out because I'm not sure it's desired. I think
	## it's good when leaving the scene but it feels sticky when entering one.
	## It also causes a bug with the camera waiting for the fade to end before
	## clicking into position in the new scene.
	#set_player_frozen(true) 
	
	#fade in
	await hud.fade_to(0.0).finished
	
	is_changing_level = false
	set_player_frozen(false)

func _setup_level(level_root: Node) -> void:
	p("setting up level...")
	
	#connect apples
	var apples = level_root.get_node_or_null("Apples")
	if apples: 
		for apple in apples.get_children():
			#apple.collected.connect(increase_applesCollected) ## moved signal to Player (health)
			pass
			
	#connect enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies: 
		for enemy in enemies.get_children():
			#enemy.gut_died.connect(_on_gut_died) ## moved signal to Player (health)
			pass
	
	# connect gut
	var players = get_tree().get_nodes_in_group(PLAYER_GROUP)
	if players:
		for node in players:
			if node is Player:
				node.died.connect(_on_gut_died)
	
	p("level setup done.")

func set_player_frozen(toot: bool) -> void:
	for n: Node in get_tree().get_nodes_in_group(PLAYER_GROUP):
		n.process_mode = Node.PROCESS_MODE_DISABLED if toot else Node.PROCESS_MODE_INHERIT

# ---------
# SIGNAL HANDLERS
# ---------
func _on_gut_died():
	if is_changing_level:
		push_warning("Gut died while level changing. Check if this is intended behavior")
		
	await load_level(current_level_path, false)
