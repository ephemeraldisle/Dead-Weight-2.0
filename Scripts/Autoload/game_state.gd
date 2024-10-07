extends Node

const DEFAULT_SPAWN := Vector2(-230, -450)

var state: Dictionary

var boss_zone_entered := false
var alternate_face := 0
var dialogue_happening := false
var introduction_running := false

func _ready() -> void:
	state = SaveManager.get_game_states()
	_set_volume_states()

func _set_volume_states() -> void:
	_set_bus_volume(g.MASTER_BUS, state.options.master_volume)
	_set_bus_volume(g.MUSIC_BUS, state.options.music_volume)
	_set_bus_volume(g.SOUND_BUS, state.options.sound_volume)

func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var volume_db := linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, volume_db)

func save_volume_level(bus: String, percent: float) -> void:
	match bus:
		g.MASTER_BUS: state.options.master_volume = percent
		g.SOUND_BUS: state.options.sound_volume = percent
		g.MUSIC_BUS: state.options.music_volume = percent
	SaveManager.update_volume(bus, percent)

func toggle_screenshake(enabled: bool) -> void:
	state.options.screenshake = enabled
	SaveManager.update_screenshake(enabled)

func toggle_beep(enabled: bool) -> void:
	state.options.heart_beep = enabled
	GameEvents.beep_toggled.emit()
	SaveManager.update_heart_beep(enabled)

func update_spawn_position(node: Node2D) -> void:
	state.spawn_point = node.get_path()
	SaveManager.update_spawn_point(node)

func get_spawn_position() -> Vector2:
	return get_node(state.spawn_point).global_position if state.spawn_point else DEFAULT_SPAWN

func total_save() -> void:
	SaveManager.update_save_data()

func unlock_gun() -> void:
	state.abilities.gun = true

func unlock_ability(ability: String) -> void:
	state.abilities[ability] = true

func register_local_save(parent_id, save_data) -> void:
	state.local[parent_id] = save_data.duplicate(true)

func reset_unsaved_actions() -> void:
	_reset_local_state()
	_reset_abilities()
	_reset_progression()
	GameEvents.emit_unsaved_reset()

func _reset_local_state() -> void:
	for thing in state.local.keys():
		if not SaveManager.save_data.local.has(thing):
			state.local.erase(thing)

func _reset_abilities() -> void:
	for ability in SaveManager.save_data.abilities:
		if not SaveManager.save_data.abilities[ability]:
			state.abilities[ability] = false

func _reset_progression() -> void:
	for progress in SaveManager.save_data.progression:
		state.progression[progress] = SaveManager.save_data.progression[progress]

func check_saved_action(action_id: int) -> bool:
	return state.local.has(action_id)

func check_ability(ability_name: String) -> bool:
	return state.abilities[ability_name]



