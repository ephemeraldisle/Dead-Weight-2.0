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
#	print("%s would like to turn %s" % [get_path(), on])
	if on and activatable and not activated:
#		print("it couldn't")
		return
	powered = on
	power_changed.emit(powered)

##THE PROBLEM IS ACTIVATION - it's not turning things off when not activated, which is like, the opposite of what we want to ahve happen^^^^

func activate() -> void:
	if activatable:
#		print("hey babe my name is %s" %get_parent().name)
		activated = true
		if _stored_state == true:
			change_power(_stored_state)

func deactivate() -> void:
	if activatable:
#		print("bye babe")
		if _stored_state == true:
			change_power(false)
		activated = false
