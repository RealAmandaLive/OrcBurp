class_name HUD extends CanvasLayer

@onready var apple_label: Label = $ApplesCollected/appleLabel
@onready var fade_rect: ColorRect = $fade
@onready var score_label: Label = %ScoreLabel
@onready var active_trap_icon: TextureRect = %ActiveTrapIcon
@onready var active_trap_count: Label = %ActiveTrapCount


#------
# FADE
#------
var _fade_tween: Tween

func _ready() -> void:
	Main.data.changed.connect(_on_data_changed)
	_on_data_changed()

func _on_data_changed() -> void:
	apple_label.text = "Apples Collected: %s" % Main.data.applesCollected
	score_label.text = "Score: %d" % Main.data.get_score()
	if Main.data.active_trap:
		active_trap_count.show()
		active_trap_icon.show()
		active_trap_count.text = "x %d" % Main.data.inventory_items.get(Main.data.active_trap, 0)
		active_trap_icon.texture = ItemDb.get_item(Main.data.active_trap).texture
	else:
		active_trap_count.hide()
		active_trap_icon.hide()


## Used to set the screen to e.g. full-black.
## Primary use case is for starting the game scene.
func force_screen_faded() -> void:
	fade_rect.modulate.a = 1.0

## Used to adjust the screen fade transparency. 1.0 for full coverage, 0.0 for totally clear.
func fade_to(alpha: float, seconds = 1.5) -> Tween:
	if _fade_tween:
		_fade_tween.kill()
	
	_fade_tween = create_tween()
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(fade_rect, "modulate:a", alpha, seconds)
	
	## Return the tween, so we can `await` the `finished` signal. 
	## It's easier to read elsewhere
	## by returning the tween so you actually see the "finished" verbiage
	return _fade_tween

func set_fade_color(c: Color) -> void:
	fade_rect.color = c
