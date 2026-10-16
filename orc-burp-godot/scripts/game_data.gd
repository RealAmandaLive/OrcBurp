class_name GameData
extends Resource

const STARTING_HEALTH = 5
const MAX_HEALTH = 5

var playerHealth: int = STARTING_HEALTH

var applesCollected: int = 0

## fun stats and counters we can optionally just ignore
## todo: persist in game state / use for high scores?
var jumpCount: int = 0
var doubleJumpCount: int = 0
var burpCount: int = 0
var tootCount: int = 0
var eatCount: int = 0
var drinkCount: int = 0
var chestCount: int = 0
var goldCount: int = 0
var gemCount: int = 0
var deathCount: int = 0
var trapCount: int = 0
var killCount: int = 0
