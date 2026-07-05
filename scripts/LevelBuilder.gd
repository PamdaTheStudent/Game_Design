extends Node2D

## Procedurally places boundary walls and a couple of interior barrels
## based on the TileMap's room size, instead of hand-placing dozens of nodes.

@export var wall_scene: PackedScene
@export var barrel_scene: PackedScene


func _ready() -> void:
	var tile_map: Node = get_tree().get_first_node_in_group("tile_map")
	if tile_map == null:
		return
	var room_size: Vector2i = tile_map.get_room_size()
	for x in range(room_size.x):
		for y in range(room_size.y):
			var is_perimeter: bool = x == 0 or y == 0 or x == room_size.x - 1 or y == room_size.y - 1
			if is_perimeter:
				_place(wall_scene, tile_map, Vector2i(x, y))
	_place(barrel_scene, tile_map, Vector2i(3, 3))
	_place(barrel_scene, tile_map, Vector2i(room_size.x - 4, room_size.y - 4))


func _place(scene: PackedScene, tile_map: Node, grid_pos: Vector2i) -> void:
	if scene == null:
		return
	var instance: Node2D = scene.instantiate()
	add_child(instance)
	instance.global_position = tile_map.grid_to_world(grid_pos)
