extends Node
class_name AbilityPowerController

signal power_changed

@export var ability_name: String
@export var powered := true


func _ready() -> void:
	power_change(GameState.check_ability(ability_name))
	GameEvents.ability_access_changed.connect(on_ability_access_changed)

func on_ability_access_changed(ability: String) -> void:
	if not ability == ability_name:
		return
	power_change(GameState.check_ability(ability_name))

func power_change(power: bool) -> void:
	powered = power
	power_changed.emit(powered)

func power_on() -> void:
	powered = true
	power_changed.emit(powered)

func power_off() -> void:
	powered = false
	power_changed.emit(powered)
