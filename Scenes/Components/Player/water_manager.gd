extends Node

const TICK_LOSS = 0.005
const TICK_DAMAGE_TRIGGER_AMOUNT = 5
const EFFECTIVELY_EMPTY_WATER_AMOUNT = 0.005

signal water_changed

@export var health_manager: Node
@export var seconds_per_tick = 1
@onready var water_percent := 1.0
@onready var timer := $Timer as Timer

var waterless_ticks = -1
var waterActive = false


func _ready() -> void:
	timer.wait_time = seconds_per_tick
	GameEvents.water_collected.connect(change_water)
	timer.timeout.connect(on_timer_timeout)
	water_changed.emit()


func on_timer_timeout() -> void:
	if waterActive:
		water_percent = max(water_percent - TICK_LOSS, 0)
		water_changed.emit()
	if water_percent <= EFFECTIVELY_EMPTY_WATER_AMOUNT:
		if waterless_ticks >= TICK_DAMAGE_TRIGGER_AMOUNT:
			health_manager.on_damage()
			waterless_ticks = 0
		else:
			waterless_ticks += 1


func change_water(value: float) -> void:
	water_percent = clamp(water_percent+value, 0, 1)
	water_changed.emit()
