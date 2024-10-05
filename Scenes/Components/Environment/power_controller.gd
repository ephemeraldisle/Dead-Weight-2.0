extends Node
class_name PowerController

signal power_changed(is_powered: bool)

@export var initial_power_state := false
@export var activatable := false

var powered := false
var _stored_state := false
var _activated := false

func _ready() -> void:
	powered = initial_power_state
	_stored_state = initial_power_state

func power_on() -> void:
	_stored_state = true
	_update_power_state()

func power_off() -> void:
	_stored_state = false
	_update_power_state()

func _update_power_state() -> void:
	var new_power_state := _stored_state and (not activatable or _activated)
	if powered != new_power_state:
		powered = new_power_state
		power_changed.emit(powered)

func activate() -> void:
	if activatable and not _activated:
		_activated = true
		_update_power_state()

func deactivate() -> void:
	if activatable and _activated:
		_activated = false
		_update_power_state()
