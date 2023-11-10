extends Node

signal water_collected(number: float)
#signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal battery_collected
signal energy_collected(number: float)
signal gun_collected
signal beep_toggled
signal full_heal
signal player_died
signal energy_percent_changed
signal health_changed


func emit_health_changed(number: int) -> void:
	health_changed.emit(number)

func emit_energy_percent_changed(number: float) -> void:
	energy_percent_changed.emit(number)

func emit_water_collected(number: float) -> void:
	water_collected.emit(number)
#
#func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
#	ability_upgrade_added.emit(upgrade, current_upgrades)

func emit_player_damaged() -> void:
	player_damaged.emit()

func emit_player_died() -> void:
	player_died.emit()

func emit_battery_collected() -> void:
	battery_collected.emit()

func emit_energy_collected(number: float) -> void:
	energy_collected.emit(number)

func emit_gun_collected() -> void:
	gun_collected.emit()

func emit_full_heal() -> void:
	full_heal.emit()
