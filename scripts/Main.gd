extends Node2D

@export var round_duration: float = 60.0
@export var wine_bottle_scene: PackedScene

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var minigame_layer: CanvasLayer = $MinigameLayer

var _active_station: Node = null
var _minigame_in_flight: bool = false


func _ready() -> void:
	player.interact_pressed.connect(_on_player_interact)
	player.item_changed.connect(_on_player_item_changed)
	minigame_layer.minigame_completed.connect(_on_minigame_completed)
	minigame_layer.minigame_abandoned.connect(_on_minigame_abandoned)
	GameManager.round_ended.connect(_on_round_ended)
	for station in get_tree().get_nodes_in_group("stations"):
		station.interact_zone.player_entered.connect(hud.show_prompt.bind("Press E to interact"))
		station.interact_zone.player_exited.connect(hud.hide_prompt)
	for counter in get_tree().get_nodes_in_group("counters"):
		counter.interact_zone.player_entered.connect(hud.show_prompt.bind("Press E to use the counter"))
		counter.interact_zone.player_exited.connect(hud.hide_prompt)
	for king_table in get_tree().get_nodes_in_group("king_table"):
		king_table.interact_zone.player_entered.connect(hud.show_prompt.bind("Press E to submit wine to the King"))
		king_table.interact_zone.player_exited.connect(hud.hide_prompt)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			if GameManager.current_state == GameManager.GameState.BUILD:
				if hud.is_round_over_showing():
					hud.dismiss_round_over()
				else:
					GameManager.start_round(round_duration)
		elif event.keycode == KEY_F3:
			GameManager.toggle_debug_hitboxes()


func _on_player_interact(target: Node) -> void:
	if GameManager.current_state != GameManager.GameState.ROUND:
		return
	if target.is_in_group("king_table"):
		_submit_to_king()
		return
	if target.is_in_group("stations") or target.is_in_group("counters"):
		_interact_surface(target)


func _interact_surface(surface: Node) -> void:
	if player.carried_item != null:
		if surface.has_item():
			return
		surface.place_item(player.put_down())
		return
	if surface.has_item():
		player.pick_up(surface.take_item())
		return
	if surface.is_in_group("stations") and surface.minigame_scene != null and not _minigame_in_flight:
		_active_station = surface
		_minigame_in_flight = true
		GameManager.enter_minigame(surface)
		minigame_layer.launch(surface.minigame_scene)


func _submit_to_king() -> void:
	if player.carried_item == null:
		return
	player.put_down().queue_free()
	GameManager.end_round()


func _on_minigame_completed(score: float) -> void:
	_minigame_in_flight = false
	GameManager.exit_minigame(score)
	if _active_station != null:
		_spawn_wine_bottle_on(_active_station)
		_active_station = null


func _on_minigame_abandoned() -> void:
	GameManager.leave_minigame_early()


func _on_round_ended(_final_score: float) -> void:
	## A round can now end while a minigame is running (visible or
	## backgrounded) since the room timer ticks during MINIGAME state too -
	## force it closed so a stale instance doesn't bleed into BUILD phase.
	if _minigame_in_flight:
		_minigame_in_flight = false
		_active_station = null
		minigame_layer.close_current()


func _spawn_wine_bottle_on(surface: Node) -> void:
	if wine_bottle_scene == null:
		return
	var bottle: Node2D = wine_bottle_scene.instantiate()
	surface.place_item(bottle)


func _on_player_item_changed(item: Node2D) -> void:
	hud.set_carrying(item != null)
