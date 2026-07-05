extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var score_label: Label = $ScoreLabel
@onready var prompt_label: Label = $PromptLabel
@onready var build_mode_indicator: Label = $BuildModeIndicator
@onready var round_over_panel: Panel = $RoundOverPanel
@onready var round_over_label: Label = $RoundOverPanel/RoundOverLabel
@onready var carry_label: Label = $CarryLabel


func _ready() -> void:
	GameManager.state_changed.connect(_on_state_changed)
	GameManager.score_updated.connect(_on_score_updated)
	GameManager.round_ended.connect(_on_round_ended)
	round_over_panel.visible = false
	prompt_label.visible = false
	carry_label.visible = false
	_on_state_changed(GameManager.current_state)
	_on_score_updated(GameManager.round_score)


func _process(_delta: float) -> void:
	if GameManager.current_state == GameManager.GameState.ROUND:
		timer_label.text = "Time: %d" % int(ceil(GameManager.round_time_left))
	else:
		timer_label.text = ""


func _on_state_changed(new_state: GameManager.GameState) -> void:
	build_mode_indicator.visible = (new_state == GameManager.GameState.BUILD)
	if new_state != GameManager.GameState.BUILD:
		round_over_panel.visible = false


func _on_score_updated(new_total: float) -> void:
	score_label.text = "Wine Quality: %d" % int(new_total)


func _on_round_ended(final_score: float) -> void:
	round_over_label.text = "Batch submitted to the Vampire King!\nFinal Quality: %d\nPress ENTER to return to Build phase." % int(final_score)
	round_over_panel.visible = true


func show_prompt(text: String) -> void:
	prompt_label.text = text
	prompt_label.visible = true


func hide_prompt() -> void:
	prompt_label.visible = false


func set_carrying(is_carrying: bool) -> void:
	carry_label.visible = is_carrying


func is_round_over_showing() -> bool:
	return round_over_panel.visible


func dismiss_round_over() -> void:
	round_over_panel.visible = false
