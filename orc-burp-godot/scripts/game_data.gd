class_name GameData
extends Resource

signal health_changed(new_health: int)
signal costume_changed(new_costume: String)

const STARTING_HEALTH = 10
const MAX_HEALTH = 10

@export var playerHealth: int = STARTING_HEALTH : 
	set(v):
		playerHealth = clampi(v, 0, MAX_HEALTH)
		emit_changed()
		health_changed.emit(playerHealth)

var applesCollected: int = 0

# The key of the dictionary is the levelName
# The value is a list of item paths that have already been collected
@export var levelItems: Dictionary[String, Array] = {}
# Key=levelName, Value=has the player solved the puzzle?
@export var solvedPuzzles: Dictionary[String, bool] = {}
# Key=levelName, Value=has the player turned on the lights?
@export var turnedOnLights: Dictionary[String, bool] = {}
@export var lastLocation: Dictionary[String, Vector2] = {}
@export var unlockedDoors: Dictionary[String, bool] = {}

@export var levelName: String

## fun stats and counters we can optionally just ignore
## todo: persist in game state / use for high scores?
@export var jumpCount: int = 0
@export var doubleJumpCount: int = 0
@export var burpCount: int = 0
@export var tootCount: int = 0
@export var drinkCount: int = 0
@export var chestCount: int = 0
@export var goldCount: int = 0
@export var gemCount: int = 0
@export var deathCount: int = 0
@export var trapCount: int = 0
@export var killCount: int = 0

@export var active_costume: String = "":
	set(v):
		if v == "" or costumes_collection.has(v):
			active_costume = v
			costume_changed.emit(v)

@export var active_trap: String = "":
	set(v):
		if v == "" or inventory_items.has(v):
			active_trap = v
			changed.emit()

# Inventory items and costumes data - {item_name: qty}
@export var inventory_items: Dictionary[String, int] = {}
@export var costumes_collection: Dictionary[String, int] = {}

# use this to increment counters and things
# it will automatically emit the changed event, which will let
# the HUD know it needs to update
func inc(property: StringName, by = 1) -> void:
	var v = get(property)
	set(property, int(v) + by)
	emit_changed()


func _get_item_key(item_node: Node) -> String:
	# TODO: This doesn't work for treasure chest or barrel state spawned items
	# Instead we will have to track the "opened state" of those
	# Not sure of why we skip to the 4th element in nodepath but this returns null for those
	# so just return empty in that case and skip in caller
	var sliced_path:NodePath = item_node.get_path().slice(3)
	if sliced_path:
		return sliced_path.get_concatenated_names()
	else:
		# TODO: Remove this warning once this case is handled
		push_warning("GameData: Could not get sliced path for node=%s" % item_node.get_path())
		return ""

func is_item_taken(item_node: Node) -> bool:
	if not levelItems.has(levelName):
		levelItems[levelName] = []
	var item_key: String = _get_item_key(item_node)
	return levelItems[levelName].find(item_key) >= 0 if item_key else false


func record_item_taken(item_node: Node) -> void:
	if not levelItems.has(levelName):
		levelItems[levelName] = []
	var item_key: String = _get_item_key(item_node)
	if item_key and levelItems[levelName].find(item_key) < 0:
		levelItems[levelName].append(item_key)


func has_solved_puzzle() -> bool:
	return solvedPuzzles.get(levelName, false)


func record_puzzle_solved() -> void:
	solvedPuzzles[levelName] = true


func has_turned_on_lights() -> bool:
	return turnedOnLights.get(levelName, false)


func record_lights_turned_on() -> void:
	turnedOnLights[levelName] = true


func record_location(global_pos: Vector2) -> void:
	lastLocation[levelName] = global_pos


func get_last_location() -> Vector2:
	return lastLocation.get(levelName, Vector2.INF)


func has_last_location() -> bool:
	return lastLocation.has(levelName)


func _get_door_key(node: LevelExit) -> String:
	return "%s:%s" % [levelName, _get_item_key(node)]


func has_unlocked_door(exitNode: LevelExit) -> bool:
	return unlockedDoors.get(_get_door_key(exitNode), false)


func record_unlocked_door(exitNode: LevelExit) -> void:
	unlockedDoors[_get_door_key(exitNode)] = true


func get_key_count() -> int:
	return inventory_items.get("key", 0)


func add_item_to_inventory(item_name, qty) -> void:
	if inventory_items.has(item_name):
		inventory_items[item_name] += qty
	else:
		inventory_items[item_name] = qty
	emit_changed()

func remove_item_from_inventory(item_name, qty) -> void:
	if not inventory_items.has(item_name): return
	
	if inventory_items[item_name]-qty <= 0:
		inventory_items.erase(item_name)
	else:
		inventory_items[item_name] -= qty
		
	emit_changed()

func add_costume_to_collection(costume) -> void:
	costumes_collection[costume] = 1
	emit_changed()


func reset_player_health() -> void:
	playerHealth = STARTING_HEALTH


func get_score() -> int:
	return 42
