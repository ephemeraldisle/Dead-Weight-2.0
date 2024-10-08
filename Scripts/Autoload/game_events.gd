extends Node

# Player-related signals
signal player_damaged
signal health_changed(number: int)
signal full_heal

# Resource-related signals
signal water_collected(number: float)
signal energy_collected(number: float)
signal energy_percent_changed(number: float)
signal battery_collected

# Ability-related signals
signal ability_access_changed(ability: String)
signal gun_collected

# UI and game state signals
signal beep_toggled
signal dialogue_started
signal dialogue_ended
signal unsaved_reset

# Emit functions
func emit_dialogue_started() -> void:
	dialogue_started.emit()

func emit_dialogue_ended() -> void:
	dialogue_ended.emit()

func emit_health_changed(number: int) -> void:
	health_changed.emit(number)

func emit_energy_percent_changed(number: float) -> void:
	energy_percent_changed.emit(number)

func emit_water_collected(number: float) -> void:
	water_collected.emit(number)

func emit_ability_access_changed(ability: String) -> void:
	ability_access_changed.emit(ability)

func emit_player_damaged() -> void:
	player_damaged.emit()

func emit_battery_collected() -> void:
	battery_collected.emit()

func emit_energy_collected(number: float) -> void:
	energy_collected.emit(number)

func emit_gun_collected() -> void:
	gun_collected.emit()

func emit_full_heal() -> void:
	full_heal.emit()

func emit_unsaved_reset() -> void:
	unsaved_reset.emit()