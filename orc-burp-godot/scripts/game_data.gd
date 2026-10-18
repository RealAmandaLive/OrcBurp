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
