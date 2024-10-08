class_name EnergyManager
extends Node2D

signal energy_changed
signal bars_changed

const BARS_PER_BATTERY := 4.0
const ENERGY_RECHARGE_RATE := 0.005
const MIN_ENERGY := -0.9999
const ROUNDING_OFFSET := 0.9999

var current_batteries: int
var max_bars: int
var current_bars: int
var max_energy: float
var current_energy: float
var previous_bars: int

func _ready() -> void:
	_calculate_battery_energy()
	GameEvents.battery_collected.connect(_on_battery_collected)
	GameEvents.energy_collected.connect(_on_energy_pickup_collected)
	GameEvents.energy_percent_changed.connect(change_energy)
	SharedPlayerManager.player_spawned.connect(_on_player_spawned)

func _physics_process(_delta: float) -> void:
	_adjust_bars()
	if current_bars >= 0 and current_energy < max_energy and current_energy > 0:
		change_energy(ENERGY_RECHARGE_RATE)

func _adjust_bars() -> void:
	previous_bars = current_bars
	current_bars = int(floor(current_energy))
	if current_bars != previous_bars:
		bars_changed.emit()

func change_energy(percent: float) -> void:
	current_energy = clamp(current_energy + percent, MIN_ENERGY, current_bars + ROUNDING_OFFSET)
	energy_changed.emit()

func _calculate_battery_energy() -> void:
	current_batteries = GameState.state.progression.batteries
	max_bars = int(current_batteries * BARS_PER_BATTERY)
	current_bars = max_bars
	max_energy = float(current_bars)
	current_energy = max_energy

func _on_battery_collected() -> void:
	current_batteries += 1
	_calculate_battery_energy()

func _on_energy_pickup_collected(number: float) -> void:
	change_energy(number)

func _on_player_spawned() -> void:
	current_bars = max_bars
	current_energy = max_energy
	energy_changed.emit()