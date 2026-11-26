class_name LootSpawner extends Node

@export
var config:LootTable

func _ready() -> void:
	assert(config)
	if not config:
		push_error("%s: No config set on loot spawner!" % name)
	
func spawn(position:Vector2, attachment_override:Node = null) -> Array[Node2D]:
	# Add to parent of the owner scene
	var spawned_array:Array[Node2D]
	
	if not config:
		return spawned_array
	
	var attachment:Node
	if is_instance_valid(attachment_override):
		attachment = attachment_override
	else:
		var ref_point:Node = owner as Node2D
		if not ref_point:
			ref_point = get_parent() as Node2D
			if not ref_point:
				ref_point = self
		attachment = ref_point.get_parent()
	
	spawned_array = config.spawn()
	for spawned in spawned_array:
		spawned.position = position
		
		var spawned_scene_name := spawned.scene_file_path.get_basename()
		spawned_scene_name = spawned_scene_name.get_file()
		
		spawned.name = "%s_%s" % [get_parent().name, spawned_scene_name]
		
		attachment.add_child(spawned)
		
	return spawned_array
