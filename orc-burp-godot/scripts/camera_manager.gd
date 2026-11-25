class_name CameraManager
extends Camera2D


func _ready() -> void:
	var path: Path2D = get_parent().get_node_or_null("CameraPathOnLoad")
	if path:
		showcase_path.call_deferred(path)

func _wait_a_bit() -> void:
	await get_tree().create_timer(0.5).timeout


func tween_to_location(gpos: Vector2, seconds: float = 1.0) -> Tween:
	var t = create_tween()
	t.set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_SINE)
	t.tween_property(self, "global_position", gpos, seconds)
	return t


func showcase_path(path: Path2D, seconds: float = 0.0) -> void:
	get_tree().paused = true
	
	# temporarily move the camera under a PathFollow2D node
	var real_parent = get_parent()
	var path_follow: PathFollow2D = PathFollow2D.new()
	path_follow.cubic_interp = true
	path_follow.process_mode = Node.PROCESS_MODE_ALWAYS
	path.add_child(path_follow)
	reparent(path_follow, false)
	path_follow.progress_ratio = 0.0
	
	# figure out how long we should take to follow the path
	var real_seconds: float = seconds
	if seconds <= 0.0:
		if path.has_meta("seconds_of_panning"):
			real_seconds = path.get_meta("seconds_of_panning")
		else:
			real_seconds = 5.0

	# follow the path
	var t = create_tween()
	t.tween_property(path_follow, "progress_ratio", 1.0, real_seconds)
	await t.finished

	# put things back
	reparent(real_parent, true)
	path_follow.queue_free()
	await tween_to_location(get_parent().global_position).finished
	get_tree().paused = false


func showcase_location(target: Node2D, seconds = 1.0, await_while_showcased: Callable = _wait_a_bit) -> void:
	get_tree().paused = true
	await tween_to_location(target.global_position, seconds).finished
	await await_while_showcased.call()
	await tween_to_location(get_parent().global_position, seconds).finished
	get_tree().paused = false
