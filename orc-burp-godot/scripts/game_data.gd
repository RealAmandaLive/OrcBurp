class_name GameData
extends Resource

signal health_changed(new_health: int)

const STARTING_HEALTH = 10
const MAX_HEALTH = 10

var playerHealth: int = STARTING_HEALTH : 
	set(v):
		playerHealth = clampi(v, 0, MAX_HEALTH)
		emit_changed()
		health_changed.emit(playerHealth)

var applesCollected: int = 0

# The key of the dictionary is the levelName
# The value is a list of item paths that have already been collected
var levelItems: Dictionary[String, Array] = {}
# Key=levelName, Value=has the player collected the key?
var levelKeys: Dictionary[String, bool] = {}

var levelName: String

## fun stats and counters we can optionally just ignore
## todo: persist in game state / use for high scores?
var jumpCount: int = 0
var doubleJumpCount: int = 0
var burpCount: int = 0
var tootCount: int = 0
var drinkCount: int = 0
var chestCount: int = 0
var goldCount: int = 0
var gemCount: int = 0
var deathCount: int = 0
var trapCount: int = 0
var killCount: int = 0

# use this to increment counters and things
# it will automatically emit the changed event, which will let
# the HUD know it needs to update
func inc(property: StringName, by = 1) -> void:
	var v = get(property)
	set(property, int(v) + by)
	emit_changed()


func _get_item_key(item_node: Node) -> String:
	return item_node.get_path().slice(3).get_concatenated_names()


func is_item_taken(item_node: Node) -> bool:
	if not levelItems.has(levelName):
		levelItems[levelName] = []
	var item_key: String = _get_item_key(item_node)
	return levelItems[levelName].find(item_key) >= 0


func record_item_taken(item_node: Node) -> void:
	if not levelItems.has(levelName):
		levelItems[levelName] = []
	var item_key: String = _get_item_key(item_node)
	if levelItems[levelName].find(item_key) < 0:
		levelItems[levelName].append(item_key)


func has_level_key() -> bool:
	return levelKeys.get(levelName, false)


func record_level_key() -> void:
	levelKeys[levelName] = true
