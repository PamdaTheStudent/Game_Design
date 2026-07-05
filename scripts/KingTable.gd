extends StaticBody2D

## Always interactable during a round (not draggable, no lock/unlock state).
## Main.gd checks the "king_table" group to route interaction here instead
## of into a minigame.

@onready var interact_zone: Area2D = $InteractZone


func _ready() -> void:
	add_to_group("king_table")
