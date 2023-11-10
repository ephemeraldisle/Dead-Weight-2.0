extends Node

signal save_updated

var completed = false

@onready var parent_id = get_parent().get_path()

func _ready() -> void:
	GameEvents.player_died.connect(on_player_died)
	reset()
	
func reset() -> void:
	if completed != GameState.state.local.has(parent_id):
		completed = GameState.state.local[parent_id]

func on_player_died() -> void:
	reset()
