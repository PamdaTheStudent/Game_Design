extends CharacterBody2D

signal interact_pressed(target: Node)
signal item_changed(item: Node2D)

const CARRY_OFFSET := Vector2(0, -40)

@export var speed: float = 220.0

var carried_item: Node2D = null

var _nearby_targets: Array = []

@onready var interact_area: Area2D = $InteractArea
@onready var _interact_shape: CircleShape2D = $InteractArea/CollisionShape2D.shape


func _ready() -> void:
	interact_area.area_entered.connect(_on_interact_area_entered)
	interact_area.area_exited.connect(_on_interact_area_exited)
	GameManager.debug_hitboxes_toggled.connect(_on_debug_toggled)


func _physics_process(_delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.MINIGAME:
		velocity = Vector2.ZERO
		return
	velocity = _get_input_direction() * speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	var is_interact_key: bool = event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E
	var is_interact_click: bool = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if is_interact_key or is_interact_click:
		if GameManager.current_state == GameManager.GameState.ROUND:
			var target: Node = get_nearby_target()
			if target != null:
				interact_pressed.emit(target)


func _get_input_direction() -> Vector2:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	return dir.normalized()


func pick_up(item: Node2D) -> void:
	carried_item = item
	if item.get_parent():
		item.get_parent().remove_child(item)
	add_child(item)
	item.position = CARRY_OFFSET
	item_changed.emit(item)


func put_down() -> Node2D:
	var item: Node2D = carried_item
	if item:
		remove_child(item)
	carried_item = null
	item_changed.emit(null)
	return item


func get_nearby_target() -> Node:
	## Multiple interact zones can overlap (e.g. furniture dragged close
	## together in Build phase) - always resolve to the closest one instead
	## of whichever fired an area_entered signal last.
	var closest: Node = null
	var closest_dist: float = INF
	for target in _nearby_targets:
		if not is_instance_valid(target):
			continue
		var dist: float = global_position.distance_to(target.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = target
	return closest


func _on_interact_area_entered(area: Area2D) -> void:
	if not area.is_in_group("interact_zone"):
		return
	var target: Node = area.get_parent()
	if not _nearby_targets.has(target):
		_nearby_targets.append(target)


func _on_interact_area_exited(area: Area2D) -> void:
	if not area.is_in_group("interact_zone"):
		return
	_nearby_targets.erase(area.get_parent())


func _on_debug_toggled(_enabled: bool) -> void:
	queue_redraw()


func _draw() -> void:
	if not GameManager.debug_hitboxes_enabled:
		return
	draw_circle(Vector2.ZERO, _interact_shape.radius, Color(1.0, 0.9, 0.2, 0.35))
