extends Node

var state := {
	"version": 0.00,
	"spawn_point": Vector2(166, 84),
	"options":
	{
		"screenshake": true,
		"master_volume": 0.5,
		"music_volume": 0.5,
		"sound_volume": 0.5,
		"heart_beep": true,
	},
	"progression":
	{
		"tutorial_complete": false,
		"options_visited": false,
		"introduction_watched": false,
		"batteries": 1,
	},
	"abilities":
	{
		"jetpack": false,
		"rotation": false,
		"death": false,
		"gun": false,
		"shield": false,
		"magnet": false
	},
	"local": {},
}

var boss_zone_entered = false
var alternate_face = 0
var dialogue_happening = false
var introduction_running = false


func _ready() -> void:
	state = SaveManager.get_game_states()
	GameEvents.player_died.connect(reset_unsaved_actions)
	_set_volume_states()


func _set_volume_states() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	var volume_db = linear_to_db(state.options.master_volume)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	bus_index = AudioServer.get_bus_index("Music")
	volume_db = linear_to_db(state.options.music_volume)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	bus_index = AudioServer.get_bus_index("Sounds")
	volume_db = linear_to_db(state.options.sound_volume)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func save_volume_level(bus: String, percent: float) -> void:
	if bus == "Master":
		state.options.master_volume = percent
	if bus == "Sounds":
		state.options.sound_volume = percent
	if bus == "Music":
		state.options.music_volume = percent
	SaveManager.update_volume(bus, percent)


func toggle_screenshake(enabled: bool) -> void:
	state.options.screenshake = enabled
	SaveManager.update_screenshake(enabled)


func toggle_beep(enabled: bool):
	state.options.heart_beep = enabled
#	GameEvents.beep_toggled.emit()
	SaveManager.update_heart_beep(enabled)


func update_spawn_position(pos: Vector2):
	state.spawn_point = pos
	SaveManager.update_spawn_point(pos)


func total_save() -> void:
	print_debug("big ol save")
	SaveManager.update_save_data()


func unlock_gun() -> void:
	state.abilities.gun = true


func register_local_save(parent_id, save_data) -> void:
	print_debug("registering local save")
	state.local[parent_id] = save_data.duplicate(true)


func reset_unsaved_actions() -> void:
#	print_debug("resetting")
	for thing in state.local:
		if !SaveManager.save_data.local.has(thing):
			state.local.erase(thing)
#	GameEvents.emit_player_died()
	for ability in SaveManager.save_data.abilities:
		if SaveManager.save_data.abilities[ability] == false:
			state.abilities[ability] = false
	for progress in SaveManager.save_data.progression:
		state.progression[progress] = SaveManager.save_data.progression[progress]
	GameEvents.emit_unsaved_reset()

func check_saved_action(action_id: int) -> bool:
	if state.local.has(action_id):
		return true
	else:
		return false


func check_ability(ability_name: String) -> bool:
	return state.abilities[ability_name]
