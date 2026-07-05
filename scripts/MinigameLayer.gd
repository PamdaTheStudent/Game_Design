extends CanvasLayer

signal minigame_completed(score: float)
signal minigame_abandoned

var _current_instance: Node = null


func launch(scene: PackedScene) -> void:
	close_current()
	if scene == null:
		return
	_current_instance = scene.instantiate()
	add_child(_current_instance)
	if _current_instance.has_signal("completed"):
		_current_instance.completed.connect(_on_minigame_completed)
	if _current_instance.has_signal("abandoned"):
		_current_instance.abandoned.connect(_on_minigame_abandoned)


func _on_minigame_completed(score: float) -> void:
	minigame_completed.emit(score)
	close_current()


func _on_minigame_abandoned() -> void:
	## The instance keeps running hidden until it finishes on its own and
	## fires _on_minigame_completed - do not close it here.
	minigame_abandoned.emit()


func close_current() -> void:
	if _current_instance:
		_current_instance.queue_free()
		_current_instance = null
