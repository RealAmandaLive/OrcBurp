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
var _rand_gen := RandomNumberGenerator.new()

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
	var entry_weights := _compute_weights(viable_entries)
	
	for i in count:
		var choice:int = _rand_gen.rand_weighted(entry_weights)
		if choice != -1:
			var entry := viable_entries[choice]
			spawned.push_back(entry.spawn())
	
	if OS.is_debug_build():
		print_debug("%s: Requesting spawn: %s from count of %d" % [resource_path, spawned, count])
		
	return spawned
		
func _initialize() -> void:
	# Remove invalid
	for i in range(entries.size() - 1, -1, -1):
		if not entries[i].validate():
			entries.remove_at(i)
	
	# Swap so min <= max
	if max_count < min_count:
		push_warning("%s: min_count < max_count - applied swap" % resource_path)
		var tmp:int = max_count
		max_count = min_count
		min_count = tmp
	min_count = maxi(min_count, 1)
	max_count = maxi(max_count, 1)
		
	_init = true

static func _compute_weights(values:Array[LootTableEntry]) -> PackedFloat32Array:
	var weights:PackedFloat32Array
	weights.resize(values.size())
	
	# If all weights are 0 then make them all 1 as otherwise rand_weighted won't pick anything
	if values.all(func(entry) -> bool: return is_zero_approx(entry.weight)):
		weights.fill(1.0)
	else:
		for i in values.size():
			weights[i] = values[i].weight

	return weights
