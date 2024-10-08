extends Node
class_name SaveData

const RANDOM_DELAY = 0.01
const RANDOM_MULTIPLIER = 0.5

signal save_updated

@export var _default_save_data: Dictionary

@onready var save_data = _default_save_data.duplicate(true)
@onready var parent_id = get_parent().get_path()

func _ready() -> void:
	GameEvents.unsaved_reset.connect(_on_unsaved_reset)
	reset()
	
func reset() -> void:
	if GameState.state.local.has(parent_id):
		save_data = GameState.state.local[parent_id].duplicate(true)
	else: 
		save_data = _default_save_data.duplicate(true)
	save_updated.emit()

func get_data(key):
	return save_data[key] 

func update_data(key, value) -> void:
	save_data[key] = value
	GameState.register_local_save(parent_id, save_data)

func _on_unsaved_reset() -> void:
	await get_tree().create_timer(randfn(RANDOM_DELAY, RANDOM_DELAY * RANDOM_MULTIPLIER)).timeout
	reset()
