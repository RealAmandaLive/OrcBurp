extends Node
class_name ItemDB

@export var items : Array[ItemData] = []

var lookup : Dictionary = {}

func _ready() -> void:
	for item in items:
		if item:
			lookup[item.id] = item

func get_item(id: String):
	if lookup.has(id):
		return lookup[id]
	
	push_warning("Item %s not found" % id)
	return null
