extends Node

var save_data := {}
var _initialized := false

func _ready() -> void:
	load_save_file()
	_initialized = true

func load_save_file() -> void:
	if not FileAccess.file_exists(g.SAVE_FILE_PATH):
		save_data = GlobalConsts.get_default_game_state()
		return
	var file := FileAccess.open(g.SAVE_FILE_PATH, FileAccess.READ)
	save_data = file.get_var()
# 	_migrate_save_data_if_needed()

# func _migrate_save_data_if_needed() -> void:
# 	if save_data.version < g.CURRENT_VERSION:
# 		# Implement migration logic here
# 		save_data.version = g.CURRENT_VERSION
# 		save()

func save() -> void:
	var file := FileAccess.open(g.SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(save_data)

func update_volume(bus: String, percent: float) -> void:
	match bus:
		g.MASTER_BUS: save_data.options.master_volume = percent
		g.SOUND_BUS: save_data.options.sound_volume = percent
		g.MUSIC_BUS: save_data.options.music_volume = percent
	save()

func update_screenshake(enabled: bool) -> void:
	save_data.options.screenshake = enabled
	save()

func update_heart_beep(enabled: bool) -> void:
	save_data.options.heart_beep = enabled
	save()

func update_spawn_point(spawn_point: Node2D) -> void:
	save_data.spawn_point = spawn_point.get_path()
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
	if not _initialized:
		printerr("GameState requested data before SaveManager is ready")
	return save_data.duplicate(true)