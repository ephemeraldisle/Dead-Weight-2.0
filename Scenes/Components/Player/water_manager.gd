extends Node

signal water_changed

const SECONDS_PER_TICK = 1
const TICK_LOSS = 0.005
const TICK_DAMAGE_TRIGGER_AMOUNT = 5
const EFFECTIVELY_EMPTY_WATER_AMOUNT = 0.005

@export var health_manager: Node

var _waterless_ticks = -1
var _waterActive = false

@onready var water_percent := 1.0
@onready var _timer := $Timer as Timer

func _ready() -> void:
	_timer.wait_time = SECONDS_PER_TICK
	GameEvents.water_collected.connect(_change_water)
	SharedPlayerManager.player_spawned.connect(_on_player_spawned)
	_timer.timeout.connect(_on_timer_timeout)
	water_changed.emit()


func _on_timer_timeout() -> void:
	if _waterActive:
		water_percent = max(water_percent - TICK_LOSS, 0)
		water_changed.emit()
	if water_percent <= EFFECTIVELY_EMPTY_WATER_AMOUNT:
		if _waterless_ticks >= TICK_DAMAGE_TRIGGER_AMOUNT:
			health_manager.on_damage()
			_waterless_ticks = 0
		else:
			_waterless_ticks += 1


func _change_water(value: float) -> void:
	water_percent = clamp(water_percent+value, 0, 1)
	water_changed.emit()

func _on_player_spawned() -> void:
	water_percent = 1.0
	water_changed.emit()
