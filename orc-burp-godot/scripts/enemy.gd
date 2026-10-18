@tool
extends Node
class_name Enemy

@export_category("Class Variables")
@export var damage : int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D


func _ready() -> void:
	area_2d.body_entered.connect(_on_body_entered)


func _on_body_entered(body : Node2D) -> void:
	if body is Player:
		body.take_damage(damage)
