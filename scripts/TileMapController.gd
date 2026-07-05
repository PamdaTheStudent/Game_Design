extends TileMapLayer

## Passive utility: defines the floor visuals + grid coordinate system.
## Everything else asks this node to convert between world and grid space.

@export var room_size: Vector2i = Vector2i(24, 14)


func _ready() -> void:
	add_to_group("tile_map")
	_paint_floor()


func _paint_floor() -> void:
	for x in range(room_size.x):
		for y in range(room_size.y):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0))


func world_to_grid(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))


func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(grid_pos))


func is_grid_cell_free(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.y >= 0 and grid_pos.x < room_size.x and grid_pos.y < room_size.y


func get_room_size() -> Vector2i:
	return room_size
