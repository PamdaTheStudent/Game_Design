extends Area2D

signal player_entered
signal player_exited

@onready var _shape: CircleShape2D = $CollisionShape2D.shape


func _ready() -> void:
	add_to_group("interact_zone")
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	GameManager.debug_hitboxes_toggled.connect(_on_debug_toggled)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interact"):
		player_entered.emit()


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interact"):
		player_exited.emit()


func _on_debug_toggled(_enabled: bool) -> void:
	queue_redraw()


func _draw() -> void:
	if not GameManager.debug_hitboxes_enabled:
		return
	draw_circle(Vector2.ZERO, _shape.radius, Color(0.2, 0.9, 1.0, 0.35))
