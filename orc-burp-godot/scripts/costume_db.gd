extends Node
class_name CostumeDB

@export var costumes : Array[CostumeData] = []

var lookup : Dictionary = {}

func _ready() -> void:
	for costume in costumes:
		if costume:
			lookup[costume.id] = costume

func get_costume(id: String):
	if lookup.has(id):
		return lookup[id]
	
	push_warning("costume %s not found" % id)
	return null
