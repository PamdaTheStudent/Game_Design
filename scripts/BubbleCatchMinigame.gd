extends Control

## Fully self-contained: does not know GameManager, Station, or the grid exist.
## Can be built and tested completely on its own by running this scene directly.

signal completed(quality_score: float)
signal abandoned

@export var duration: float = 20.0
@export var target_potency: float = 75.0

const GOOD_COLOR := Color(0.75, 0.1, 0.15)
const BAD_COLOR := Color(0.15, 0.15, 0.18)
const GOOD_CHANCE := 0.65
const GOOD_GAIN := 5.0
const BAD_PENALTY := 9.0
const SUCK_RADIUS := 28.0
const SPAWN_INTERVAL := 0.5
const BUBBLE_SPEED_MIN := 90.0
const BUBBLE_SPEED_MAX := 150.0
const BUBBLE_RADIUS := 15.0
const ABANDON_DECAY_PER_SECOND := 6.0

var current_potency: float = 50.0
var time_left: float = 0.0

var _active_bubbles: Array = []
var _spawn_timer: float = 0.0
var _finished: bool = false
var _abandoned: bool = false
var _max_reach: float = 240.0

@onready var play_area: Control = $MinigameWindow/PlayArea
@onready var nozzle: Node2D = $MinigameWindow/PlayArea/Nozzle
@onready var suck_zone: Area2D = $MinigameWindow/PlayArea/SuckZone
@onready var time_bar: ProgressBar = $MinigameWindow/UI/TimeBar
@onready var potency_bar: ProgressBar = $MinigameWindow/UI/PotencyBar


func _ready() -> void:
	time_left = duration
	current_potency = 50.0
	time_bar.max_value = duration
	time_bar.value = duration
	potency_bar.max_value = 100.0
	potency_bar.value = current_potency
	nozzle.position = Vector2(play_area.size.x / 2.0, play_area.size.y - 60.0)
	_max_reach = min(play_area.size.x / 2.0 - 40.0, play_area.size.y - 80.0)


func _unhandled_input(event: InputEvent) -> void:
	if _finished or _abandoned:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_abandon()


func _abandon() -> void:
	_abandoned = true
	visible = false
	for bubble in _active_bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	_active_bubbles.clear()
	abandoned.emit()


func _process(delta: float) -> void:
	if _finished:
		return
	time_left -= delta
	time_bar.value = max(time_left, 0.0)
	if time_left <= 0.0:
		_finish()
		return

	if _abandoned:
		current_potency = max(0.0, current_potency - ABANDON_DECAY_PER_SECOND * delta)
		potency_bar.value = current_potency
		return

	var to_mouse: Vector2 = get_global_mouse_position() - nozzle.global_position
	var reach: float = min(to_mouse.length(), _max_reach)
	var reach_offset: Vector2 = to_mouse.normalized() * reach if to_mouse.length() > 0.001 else Vector2.ZERO
	nozzle.look_at(nozzle.global_position + reach_offset)
	suck_zone.position = nozzle.position + reach_offset

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = SPAWN_INTERVAL
		_spawn_bubble()

	var suck_held: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var to_remove: Array = []
	for bubble in _active_bubbles:
		if not is_instance_valid(bubble):
			to_remove.append(bubble)
			continue
		var vel: Vector2 = bubble.get_meta("velocity")
		bubble.position += vel * delta
		if bubble.position.y > play_area.size.y + BUBBLE_RADIUS:
			to_remove.append(bubble)
			bubble.queue_free()
			continue
		if suck_held and bubble.global_position.distance_to(suck_zone.global_position) <= SUCK_RADIUS + BUBBLE_RADIUS:
			_on_bubble_caught(bubble)
			to_remove.append(bubble)
	for bubble in to_remove:
		_active_bubbles.erase(bubble)


func _spawn_bubble() -> void:
	var bubble := Area2D.new()

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = BUBBLE_RADIUS
	shape.shape = circle
	bubble.add_child(shape)

	var visual := Polygon2D.new()
	visual.polygon = _circle_points(BUBBLE_RADIUS, 14)
	var is_good: bool = randf() < GOOD_CHANCE
	visual.color = GOOD_COLOR if is_good else BAD_COLOR
	bubble.add_child(visual)

	bubble.set_meta("is_good", is_good)
	bubble.set_meta("velocity", Vector2(0, randf_range(BUBBLE_SPEED_MIN, BUBBLE_SPEED_MAX)))

	var spawn_x: float = randf_range(BUBBLE_RADIUS * 2.0, max(BUBBLE_RADIUS * 2.0 + 1.0, play_area.size.x - BUBBLE_RADIUS * 2.0))
	bubble.position = Vector2(spawn_x, -BUBBLE_RADIUS)
	play_area.add_child(bubble)
	_active_bubbles.append(bubble)


func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(segments):
		var angle: float = (float(i) / float(segments)) * TAU
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _on_bubble_caught(bubble: Node) -> void:
	var is_good: bool = bubble.get_meta("is_good")
	if is_good:
		current_potency = min(100.0, current_potency + GOOD_GAIN)
	else:
		current_potency = max(0.0, current_potency - BAD_PENALTY)
	potency_bar.value = current_potency
	bubble.queue_free()


func _finish() -> void:
	_finished = true
	for bubble in _active_bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	_active_bubbles.clear()
	completed.emit(current_potency)
