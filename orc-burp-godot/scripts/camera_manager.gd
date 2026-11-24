class_name CameraManager
extends Camera2D

func _wait_a_bit() -> void:
	await get_tree().create_timer(0.5).timeout


func showcase_location(target: Node2D, seconds = 1.0, await_while_showcased: Callable = _wait_a_bit) -> void:
	get_tree().paused = true
	var t1 = create_tween()
	t1.set_ease(Tween.EASE_IN_OUT)
	t1.set_trans(Tween.TRANS_SINE)
	t1.tween_property(self, "global_position", target.global_position, seconds)
	await t1.finished
	await await_while_showcased.call()
	var t2 = create_tween()
	t2.set_ease(Tween.EASE_IN_OUT)
	t2.set_trans(Tween.TRANS_SINE)	
	t2.tween_property(self, "position", Vector2.ZERO, seconds)
	await t2.finished
	get_tree().paused = false
