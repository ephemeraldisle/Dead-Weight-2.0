extends Node
class_name PowerController
signal power_changed

@export var powered := true

func power_on() -> void:
	powered = true
	power_changed.emit(powered)

func power_off() -> void:
	powered = false
	power_changed.emit(powered)
