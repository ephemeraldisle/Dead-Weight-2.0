class_name WaterManager
extends Node

signal water_changed

const SECONDS_PER_TICK := 1
const TICK_LOSS := 0.005
const TICK_DAMAGE_TRIGGER_AMOUNT := 5
const EFFECTIVELY_EMPTY_WATER_AMOUNT := 0.005
const FULL_WATER := 1.0
const EMPTY_WATER := 0.0
const NO_TICKS := 0
const INITIAL_WATERLESS_TICKS := -1

@export var health_manager: Node

var _waterless_ticks := INITIAL_WATERLESS_TICKS
var _water_active := false

@onready var water_percent := FULL_WATER
@onready var _timer: Timer = $Timer

func _ready() -> void:
	_timer.wait_time = SECONDS_PER_TICK
	GameEvents.water_collected.connect(_change_water)
	SharedPlayerManager.player_spawned.connect(_on_player_spawned)
	_timer.timeout.connect(_on_timer_timeout)
	water_changed.emit()

func _on_timer_timeout() -> void:
	if _water_active:
		_update_water_percent()
	_check_for_damage()

func _update_water_percent() -> void:
	water_percent = max(water_percent - TICK_LOSS, EMPTY_WATER)
	water_changed.emit()

func _check_for_damage() -> void:
	if water_percent <= EFFECTIVELY_EMPTY_WATER_AMOUNT:
		if _waterless_ticks >= TICK_DAMAGE_TRIGGER_AMOUNT:
			health_manager.on_damage()
			_waterless_ticks = NO_TICKS
		else:
			_waterless_ticks += 1

func _change_water(value: float) -> void:
	water_percent = clamp(water_percent + value, EMPTY_WATER, FULL_WATER)
	water_changed.emit()

func _on_player_spawned() -> void:
	water_percent = FULL_WATER
	water_changed.emit()

func activate_water() -> void:
	_water_active = true

func deactivate_water() -> void:
	_water_active = false