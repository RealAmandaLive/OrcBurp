class_name LootTableEntry extends Resource

## Item to spawn - must be a Node2D
@export
var item:PackedScene

## Additional properties to set on the spawned scene
@export
var item_properties:Dictionary[StringName, Variant]

## The weight for this entry - higher values increase the probability of spawn relative to others in the loot table
@export_range(0.0, 1e9, 0.1, "or_greater")
var weight:float = 1.0

func validate() -> bool:
	if not item:
		return false
	
	weight = maxf(0.0, weight)
	return true

## Can override to conditionally disable spawning of this loot
## Example: Don't spawn health if full health
func can_spawn() -> bool:
	return true
	
func spawn() -> Node2D:
	if not item:
		return null
	
	var spawned := item.instantiate()
	if not spawned:
		push_error("%s: Could not spawn scene %s" % [resource_path, item.resource_path])
		return null
	var node:Node2D = spawned as Node2D
	if not node:
		push_error("%s: item %s is not a Node2D!" % [resource_path, item.resource_path])
		node.queue_free()
		return null
		
	# Set the properties on the node
	for prop in item_properties:
		node.set(prop, item_properties[prop])
		
	return node
