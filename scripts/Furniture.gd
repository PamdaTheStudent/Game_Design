extends "res://scripts/ItemSurface.gd"

## Shared build-phase drag/snap/lock behavior for placeable furniture
## (stations, counters). Draggable and non-interactable while arranging the
## kitchen in Build phase; locked in place and interactable during a round.

@export var pick_radius: float = 32.0
@export var grid_position: Vector2i = Vector2i.ZERO

var _draggable: bool = false
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

@onready var interact_zone: Area2D = $InteractZone


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	_on_state_changed(GameManager.current_state)


func _on_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.BUILD:
		unlock()
	else:
		lock()


func lock() -> void:
	_draggable = false
	_dragging = false
	interact_zone.monitoring = true


func unlock() -> void:
	_draggable = true
	interact_zone.monitoring = false


func _unhandled_input(event: InputEvent) -> void:
	if not _draggable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos: Vector2 = get_global_mouse_position()
			if global_position.distance_to(mouse_pos) <= pick_radius:
				_on_drag_started(mouse_pos)
		elif _dragging:
			_on_drag_ended()
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() + _drag_offset


func _on_drag_started(mouse_pos: Vector2) -> void:
	_dragging = true
	_drag_offset = global_position - mouse_pos


func _on_drag_ended() -> void:
	_dragging = false
	var tile_map: Node = get_tree().get_first_node_in_group("tile_map")
	if tile_map:
		var snapped_grid: Vector2i = tile_map.world_to_grid(global_position)
		if tile_map.is_grid_cell_free(snapped_grid):
			grid_position = snapped_grid
		global_position = tile_map.grid_to_world(grid_position)
