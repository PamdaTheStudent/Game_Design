extends "res://scripts/Furniture.gd"

signal grabbed(station: Node)
signal placed(station: Node, grid_pos: Vector2i)
signal interact_requested(station: Node)

@export var station_id: String = "crush_station"
@export var minigame_scene: PackedScene


func _ready() -> void:
	add_to_group("stations")
	super()


func _on_drag_started(mouse_pos: Vector2) -> void:
	super(mouse_pos)
	grabbed.emit(self)


func _on_drag_ended() -> void:
	super()
	placed.emit(self, grid_position)


func start_minigame() -> void:
	interact_requested.emit(self)
