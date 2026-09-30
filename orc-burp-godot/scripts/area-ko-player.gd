class_name AreaKOPlayer extends Area2D

## Terminate the player if they end up here


func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D) -> void:
	if body is Player:
		print("Player in no-go-zone %s." % self)
		body.die()
