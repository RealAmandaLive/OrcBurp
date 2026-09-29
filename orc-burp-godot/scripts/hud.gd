class_name HUD extends CanvasLayer

@onready var apple_label: Label = $ApplesCollected/appleLabel
@onready var fade_rect: ColorRect = $fade

#------
# FADE
#------
var _fade_tween: Tween

## Used to set the screen to e.g. full-black.
## Primary use case is for starting the game scene.
func force_screen_faded() -> void:
	fade_rect.modulate.a = 1.0

## Used to adjust the screen fade transparency. 1.0 for full coverage, 0.0 for totally clear.
func fade_to(alpha: float) -> Tween:
	if _fade_tween:
		_fade_tween.kill()
	
	_fade_tween = create_tween()
	_fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_fade_tween.tween_property(fade_rect, "modulate:a", alpha, 1.5)
	
	## Return the tween, so we can `await` the `finished` signal. 
	## It's easier to read elsewhere
	## by returning the tween so you actually see the "finished" verbiage
	return _fade_tween
	

func on_apples_collected_changed(new_value: int) -> void:
	apple_label.text = "Apples Collected: %s" % new_value
