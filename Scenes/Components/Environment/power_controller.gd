extends Node
class_name PowerController
signal power_changed

@export var powered := true
@export var activatable := false
@onready var _stored_state = powered
var activated = false

func power_on() -> void:
	_stored_state = true
	change_power(_stored_state)

func power_off() -> void:
	_stored_state = false
	change_power(_stored_state)

func change_power(on: bool) -> void:
	if activatable and not activated:
		return
	powered = on
	power_changed.emit(powered)

func activate() -> void:
	if activatable:
		print("hey babe my name is %s" %get_parent().name)
		activated = true
		if _stored_state == true:
			change_power(_stored_state)

func deactivate() -> void:
	if activatable:
		print("bye babe")
		if _stored_state == true:
			change_power(false)
		activated = false
