class_name Ladder
extends Area2D

### This class can be added to any climbable object such as a ladder, rope, etc to enable the player to climp up
## Just add an area2d with a collisionShape2d to whatever object you want to make climable / descendable

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.enable_climbing()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.disable_climbing()
