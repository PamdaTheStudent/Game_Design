extends Node

## Single source of truth for what phase the game is in. Every other node
## asks GameManager for state rather than tracking it locally.

enum GameState { BUILD, ROUND, MINIGAME }

signal state_changed(new_state: GameState)
signal round_ended(final_score: float)
signal score_updated(new_total: float)
signal debug_hitboxes_toggled(enabled: bool)

var current_state: GameState = GameState.BUILD
var round_score: float = 0.0
var round_time_left: float = 0.0
var round_duration: float = 60.0
var debug_hitboxes_enabled: bool = false

var _station_before_minigame: Node = null
var _state_before_minigame: GameState = GameState.ROUND


func _process(delta: float) -> void:
	if current_state == GameState.ROUND or current_state == GameState.MINIGAME:
		round_time_left -= delta
		if round_time_left <= 0.0:
			round_time_left = 0.0
			end_round()


func can_move_stations() -> bool:
	return current_state == GameState.BUILD


func start_round(duration: float = 60.0) -> void:
	round_duration = duration
	round_time_left = duration
	round_score = 0.0
	score_updated.emit(round_score)
	_set_state(GameState.ROUND)


func end_round() -> void:
	_set_state(GameState.BUILD)
	round_ended.emit(round_score)


func enter_minigame(station: Node) -> void:
	if current_state != GameState.ROUND:
		return
	_station_before_minigame = station
	_state_before_minigame = current_state
	_set_state(GameState.MINIGAME)


func exit_minigame(score: float) -> void:
	round_score += score
	score_updated.emit(round_score)
	_station_before_minigame = null
	_set_state(_state_before_minigame)


func leave_minigame_early() -> void:
	## The minigame keeps simulating in the background (hidden) until it
	## finishes on its own and calls exit_minigame with the final score -
	## this just hands control of the room back to the player in the meantime.
	if current_state != GameState.MINIGAME:
		return
	_set_state(_state_before_minigame)


func _set_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(current_state)


func toggle_debug_hitboxes() -> void:
	debug_hitboxes_enabled = not debug_hitboxes_enabled
	debug_hitboxes_toggled.emit(debug_hitboxes_enabled)
