extends Area2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_right: RayCast2D = $RayCastRight

const DAMAGE: int = 1
const SPEED = 100
var direction = 1.0
var tile_map_layer = TileMapLayer

func _ready() -> void:
	tile_map_layer = _find_tile_map_layer()
	#print_rich("found tile_map_layer %s" % tile_map_layer)
	pass

func _find_tile_map_layer() -> TileMapLayer:
	var parent = self.get_parent()
	if parent.name == "Enemies":
		var level = parent.get_parent()
		return level.find_child("TileMapLayer")
	return null

func _process(delta: float) -> void:
	position.x += direction * SPEED * delta
	if direction > 0 and !ray_cast_right.is_colliding():
		_reverse_direction()
	elif direction < 0 and !ray_cast_left.is_colliding():
		_reverse_direction()

func _reverse_direction() -> void:
	direction *= -1
	animated_sprite_2d.flip_h = !animated_sprite_2d.flip_h

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
