# this script runs on a tilemap during initialization
# and spawns godot scenes in place of specific tiles
# (such as barrels, coins, treasure chests, etc)

extends TileMapLayer

@export var tile_to_scene: Dictionary[Vector2i, PackedScene] = {}

func _ready() -> void:
	print("tile_map_inits - spawning chests and barrels")
	replace_tiles_with_scenes.call_deferred() # wait for other things to settle

func replace_tiles_with_scenes() -> void:
	var target_parent := get_parent()
	var tile_size := tile_set.tile_size

	for cell_coords: Vector2i in get_used_cells():
		# this is like [5,10] as in what tile TYPE it is
		var atlas_coords := get_cell_atlas_coords(cell_coords)
		print(str(cell_coords.x)+","+str(cell_coords.y)+" contains tile "+str(atlas_coords.x)+","+str(atlas_coords.y))
		if tile_to_scene.has(atlas_coords):
			# print("this tile needs a replacement!")
			var scene: PackedScene = tile_to_scene[atlas_coords]
			erase_cell(cell_coords) # remove the placeholder tile
			var instance := scene.instantiate() as Node2D
			var world_pos := map_to_local(cell_coords)
			instance.global_position = to_global(world_pos)
			target_parent.add_child(instance) # add to game scene
