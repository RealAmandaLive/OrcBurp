## This is what we place in the world to allow the player to
## access the gridlock puzzle
class_name GridlockTriggerTile
extends Node2D

signal puzzle_activated
signal puzzle_canceled
signal puzzle_won

@export var puzzle_scene: PackedScene
@export var sprite_flash_color: Color = Color.WHITE

@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var game_canvas_layer: CanvasLayer = $GameCanvasLayer
@onready var background_screen: ColorRect = %BackgroundScreen
@onready var game_container: Control = %GameContainer

var puzzle_instance: GridLockPuzzle


func p(args): print_rich("[color=purple]GridlockTriggerTile : ", args)


func _ready() -> void:
	label.hide()


func _on_interaction_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		label.show()


func _on_interaction_zone_body_exited(body: Node2D) -> void:
	if body is Player:
		label.hide()


# pulse the sprite every now and then to catch the player's attention
func _on_pulse_timer_timeout() -> void:
	var t = create_tween()
	t.tween_property(sprite_2d, "modulate", sprite_flash_color, 0.2)
	t.tween_property(sprite_2d, "modulate", Color.WHITE, 0.8)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and label.visible:
		if puzzle_instance:
			hide_puzzle()
		else:
			show_puzzle()
	if event.is_action_pressed("ui_cancel") and puzzle_instance:
		hide_puzzle()


func show_puzzle() -> void:
	p("showing puzzle")
	puzzle_activated.emit.call_deferred()
	get_tree().paused = true
	
	if puzzle_instance:
		return
	puzzle_instance = puzzle_scene.instantiate()
	game_container.add_child(puzzle_instance)
	
	background_screen.modulate = Color.TRANSPARENT
	game_container.position = sprite_2d.get_global_transform_with_canvas().origin - sprite_2d.get_rect().size / 2.0
	game_container.size = puzzle_instance.get_ideal_size()
	game_container.scale = sprite_2d.get_rect().size / game_container.size
	game_canvas_layer.show()
	game_container.show()
	background_screen.show()
	
	var target_pos := Vector2.ZERO
	target_pos.x = get_viewport_rect().size.x / 2.0 - game_container.size.x / 2.0
	var tween := create_tween()
	tween.tween_property(background_screen, "modulate", Color.WHITE, 0.2)
	tween.parallel().tween_property(game_container, "scale", Vector2.ONE, 0.2)
	tween.parallel().tween_property(game_container, "position", target_pos, 0.2)


func hide_puzzle() -> void:
	# TODO: should we ask first?
	# TODO: animate back down?
	get_tree().paused = false
	game_canvas_layer.hide()
	game_container.hide()
	background_screen.hide()
	puzzle_instance.queue_free()
	set_deferred("puzzle_instance", null)
