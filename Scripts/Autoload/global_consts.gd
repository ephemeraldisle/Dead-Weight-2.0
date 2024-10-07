extends Node
class_name GlobalConsts

# Tween properties
const OPACITY := "modulate:a"
const DB_PROPERTY := "volume_db"
const LIGHT_OPACITY := "color:a"
const LIGHT_POWER := "energy"
const SCALE := "scale"
const PARTICLE_AMOUNT := "amount"

# Animation names
const RESET_ANIMATION := &"RESET"

# Common Variables
const INSTANT_TIME := 0.01
const NO_OPACITY := 0.0
const FULL_OPACITY := 1.0
const NO_LIGHT_POWER := 0.0
const FULL_LIGHT_POWER := 1.0
const SILENT_DB := -80.0
const NORMAL_DB := 0.0

# Gameplay variables
const PLAYER_PROJECTILE_LAYER := 5
const MAX_WATER_PERCENT := 1.0
const MAX_ENERGY_PERCENT := 4.0
const EMPTY := 0.0
const FULL := 1.0

# Settings variables
const HALF_WINDOW_SIZE := Vector2(640, 360)
const SOUND_BUS := &"Sounds"
const MUSIC_BUS := &"Music"
const MASTER_BUS := &"Master"

# Input commands
const INTERACT_BUTTON := &"interact"
const JETPACK_BUTTON := &"jump"
const MAGNET_BUTTON := &"down"
const RESTART_BUTTON := &"restart"
const LEFT_BUTTON := &"left"
const RIGHT_BUTTON := &"right"
const UP_BUTTON := &"up"
const DOWN_BUTTON := &"down"
const ZOOM_IN_BUTTON := &"zoom in"
const ZOOM_OUT_BUTTON := &"zoom out"
const PAUSE_BUTTON := &"pause"

# Save data
const SAVE_FILE_PATH := "user://game.save"
const CURRENT_VERSION := 0.2
const DEFAULT_SPAWN := Vector2(-230, -450)

const DEFAULT_GAME_STATE := {
	"version": CURRENT_VERSION,
	"spawn_point": null,
	"options": {
		"screenshake": true,
		"master_volume": 0.5,
		"music_volume": 0.5,
		"sound_volume": 0.5,
		"heart_beep": true,
	},
	"progression": {
		"tutorial_complete": false,
		"options_visited": false,
		"introduction_watched": false,
		"batteries": 1,
	},
	"abilities": {
		"jetpack": false,
		"rotation": false,
		"death": false,
		"interact": false,
		"gun": false,
		"shield": false,
		"magnet": false
	},
	"local": {},
}

static func get_default_game_state() -> Dictionary:
	return DEFAULT_GAME_STATE.duplicate(true)
