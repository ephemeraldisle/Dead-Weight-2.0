extends Node2D

signal energy_changed
signal bars_changed

const BARS_PER_BATTERY = 4.0
const ENERGY_RECHARGE_RATE = 0.005

var current_batteries
var max_bars
var current_bars
var max_energy
var current_energy
var previous_bars: int

func _ready():
	_calculate_battery_energy()
	GameEvents.battery_collected.connect(_on_battery_collected)
	GameEvents.energy_collected.connect(_on_energy_pickup_collected)
	GameEvents.energy_percent_changed.connect(change_energy)
#	change_energy(-1)
#	while true:
#		print(current_energy)
#		await get_tree().create_timer(0.5).timeout
#		print(current_energy)
#		change_energy(-0.25)
#		await get_tree().create_timer(0.5).timeout
#		print(current_energy)
#		await get_tree().create_timer(0.5).timeout
		
		
func _physics_process(_delta: float) -> void:
	_adjust_bars()
	if current_bars > 0 and current_energy < max_energy:
		change_energy(ENERGY_RECHARGE_RATE)



func _adjust_bars() -> void:
	previous_bars = current_bars
	current_bars = floor(current_energy)
	if current_bars != previous_bars:
		bars_changed.emit()


func change_energy(percent: float):
	current_energy = clamp(current_energy + percent, 0.0, current_bars+0.9999)
	energy_changed.emit()

func _calculate_battery_energy() -> void:
	current_batteries = GameState.state.progression.batteries
	max_bars = current_batteries*BARS_PER_BATTERY
	current_bars = max_bars
	max_energy = current_bars
	current_energy = max_energy


func _on_battery_collected():
	current_batteries += 1
	_calculate_battery_energy()


func _on_energy_pickup_collected(number: float):
	change_energy(number)
