class_name HealthManager
extends Node

signal health_changed
signal damaged

const HEAL_WATER_DRAIN := 0.00025
const MAX_HEALTH := 3

@export var regen_time := 10.0
@export var controller: Node
@export var water_manager: Node

var health := MAX_HEALTH

@onready var timer: Timer = $Timer

func _ready() -> void:
	GameEvents.full_heal.connect(full_heal)
	full_heal()
	timer.timeout.connect(_on_timer_timeout)
	controller.player_damaged.connect(_on_damage)

func _process(_delta: float) -> void:
	if timer.time_left > 0:
		GameEvents.emit_water_collected(-HEAL_WATER_DRAIN)
	if health == MAX_HEALTH:
		timer.stop()

func full_heal() -> void:
	health = MAX_HEALTH
	health_changed.emit()
	GameEvents.emit_health_changed(health)

func _on_damage() -> void:
	health -= 1
	damaged.emit()
	if health > 0:
		health_changed.emit()
		GameEvents.emit_health_changed(health)
		if timer.time_left > 0:
			timer.stop()
		timer.start(regen_time)
	elif health == 0:
		SharedPlayerManager.die()

func _on_timer_timeout() -> void:
	if health < MAX_HEALTH and health > 0:
		health += 1
		GameEvents.emit_health_changed(health)
		health_changed.emit()
	if health < MAX_HEALTH:
		timer.start(regen_time)