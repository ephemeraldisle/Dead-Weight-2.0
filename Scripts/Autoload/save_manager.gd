extends Node

const SAVE_FILE_PATH = "user://game.save"
const CURRENT_VERSION = 0.2

var _save_data_default := {
	"version": CURRENT_VERSION,
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

var save_data := {}
var _initliazed := false


func _ready() -> void:
#	print(_save_data_default.options.screenshake)
	load_save_file()
	_initliazed = true


func load_save_file() -> void:
	if !FileAccess.file_exists(SAVE_FILE_PATH):
		save_data = _save_data_default.duplicate(true)
		return
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()


func save() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)


func update_volume(bus: String, percent: float) -> void:
	if bus == "Master":
		save_data.options.master_volume = percent
	if bus == "Sounds":
		save_data.options.sound_volume = percent
	if bus == "Music":
		save_data.options.music_volume = percent
#	print(save_data.options)
	save()


func update_screenshake(enabled: bool) -> void:
	save_data.options.screenshake = enabled
	save()


func update_heart_beep(enabled: bool) -> void:
	save_data.options.heart_beep = enabled
	save()


func update_spawn_point(spawn_point: Vector2) -> void:
	save_data.spawn_point = spawn_point
	save()


func update_progress(key: String, value: bool) -> void:
	save_data.progression[key] = value
	save()


func update_abilities(key: String, value: bool) -> void:
	save_data.abilities[key] = value
	save()


func update_save_data() -> void:
	save_data = GameState.state.duplicate(true)
	save()


func get_game_states() -> Dictionary:
	if not _initliazed:
		printerr("GameState requested data before SaveManager is ready")
	return save_data.duplicate(true)
