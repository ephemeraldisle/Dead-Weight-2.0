extends Node

var state := {
	"version" = 0.00,
	"spawn_point" = Vector2(166, 84),	

	"options" = {
		"screenshake" = true,
		"master_volume" = 0.5,
		"music_volume" = 0.5,
		"sound_volume" = 0.5,
		"heart_beep" = true,
	},
	
	"progression" = {
		"tutorial_complete" = false,
		"options_visited" = false,
		"introduction_watched" = false,
	},
	
	"abilities" = {
		"jetpack_enabled" = false,
		"rotation_enabled" = false,
		"death_enabled" = false,
		"gun_enabled" = false,
		"shield_enabled" = false,
		"magnet_enabled" = false
	},
	
	"local" = {},	
}

var screenshake = true
var master_volume = 1
var music_volume = 1
var sound_volume = 1

var tutorial_complete = false
var options_visited = false
var jetpack_enabled = tutorial_complete
var rotation_enabled = tutorial_complete
var death_enabled = tutorial_complete
var gun_enabled = false

var shield_enabled = true
var introduction_watched = false

var spawn_point = Vector2(166, 84)
var heart_beep = true
var crates_cleared = false
var completed_actions = {}
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

func add_completed_action(actor: NodePath):
#	print_debug("adding this id %s" %actor)
	#print(actor)
	state.local[actor] = true

func total_save() -> void:
	SaveManager.update_save_data()

func unlock_gun() -> void:
	state.abilities.gun_enabled = true

func reset_unsaved_actions() -> void:
#	print_debug("resetting")
	for thing in state.local:
		if !SaveManager.save_data.local.has(thing):
			state.local.erase(thing)
#	GameEvents.emit_player_died()
	for ability in SaveManager.save_data.abilities:
		if SaveManager.save_data.abilities[ability] == false:
			state.abilities[ability] = false

func check_saved_action(action_id: int) -> bool:
	if state.local.has(action_id):
		return true
	else:
		return false

