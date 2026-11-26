class_name LootTable extends Resource

@export
var entries: Array[LootTableEntry]

## Minimum number of items
@export_range(1, 1e9, 1, "or_greater")
var min_count:int = 1

## Maximum number of items
@export_range(1, 1e9, 1, "or_greater")
var max_count:int = 1

var _init:bool

func spawn() -> Array[Node2D]:
	if not _init:
		_initialize()
	
	var spawned:Array[Node2D]

	if not entries:
		push_warning("%s: No entries configured - nothing will be spawned" % [resource_path])
		return spawned
		
	var viable_entries:Array[LootTableEntry]
	for entry in entries:
		if entry.can_spawn():
			viable_entries.push_back(entry)
	
	if not viable_entries:
		print_debug("%s: No viable entries to spawn out of %s" % [resource_path, entries])
		return spawned
	
	var count:int = randi_range(min_count, max_count)
	var chances := _compute_chances(viable_entries)
	
	for i in count:
		var prob:float = randf()
		for index in viable_entries.size():
			var chance:float = chances[index]
			if prob <= chance:
				var entry := viable_entries[index]
				spawned.push_back(entry.spawn())
				break
			# Check next most likely
			else:
				prob -= chance
	
	if OS.is_debug_build():
		print_debug("%s: Requesting spawn: %s from count of %d" % [resource_path, spawned, count])
		
	return spawned
		
func _initialize() -> void:
	# Remove invalid
	for i in range(entries.size() - 1, -1, -1):
		if not entries[i].validate():
			entries.remove_at(i)
	
	# Sort so most likely entries come first
	entries.sort_custom(func(a:LootTableEntry, b:LootTableEntry) -> bool:
		return a.weight > b.weight
	)
	
	# Swap so min <= max
	if max_count < min_count:
		push_warning("%s: min_count < max_count - applied swap" % resource_path)
		var tmp:int = max_count
		max_count = min_count
		min_count = tmp
	min_count = maxi(min_count, 1)
	max_count = maxi(max_count, 1)
		
	_init = true

static func _compute_chances(values:Array[LootTableEntry]) -> PackedFloat32Array:
	var chances:PackedFloat32Array
	chances.resize(values.size())
	
	var weight_sum:float = 0.0
	for entry in values:
		weight_sum += entry.weight
	
	if weight_sum > 0:		
		for i in values.size():
			chances[i] = values[i].weight / weight_sum
	else:
		chances.fill(1.0 / values.size())

	return chances
