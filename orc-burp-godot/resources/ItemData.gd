extends Resource
class_name ItemData

@export var id: String
@export var name: String
@export_multiline var description: String
@export var texture : Texture


# This is the simplest way to do it if we want to have
# a lot of different items that boil down to a few types
# of effects (e.g. an apple heals you a little, a potion
# heals you a lot, and a few types of traps, maybe some
# speed upgrades). If this gets too complex we can also
# create sublasses of ItemData, but that gets harder to follow
@export_group("Behaviors")
@export var heals_hp: int = 0


func apply_item_effect() -> void:
	if heals_hp > 0:
		Main.data.playerHealth += heals_hp
