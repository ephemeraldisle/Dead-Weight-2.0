extends Node2D
class_name Toggler

signal toggled_from_save

const TOGGLED_KEY := "toggled"

var objects_that_start_activated: Array[Node2D]
var objects_that_start_deactivated: Array[Node2D]
var toggled := true
var _objects_registered := false

@onready var _save_data: SaveData = $SaveData


func _ready() -> void:
	await _wait_for_objects_registration()
	_check_save_data()
	_save_data.save_updated.connect(_check_save_data)


func set_off() -> void:
	_deactivate()
	_save_data.update_data(TOGGLED_KEY, false)


func set_on() -> void:
	_activate()
	_save_data.update_data(TOGGLED_KEY, true)


func _deactivate() -> void:
	toggled = false
	_change_object_power(objects_that_start_activated, false)
	_change_object_power(objects_that_start_deactivated, true)


func _activate() -> void:
	toggled = true
	_change_object_power(objects_that_start_activated, true)
	_change_object_power(objects_that_start_deactivated, false)


func _check_save_data() -> void:
	if not _save_data.get_data(TOGGLED_KEY):
		_deactivate()
	else:
		_activate()
	toggled_from_save.emit()


func register_active_objects(objects: Array[Node2D]) -> void:
	_objects_registered = true
	objects_that_start_activated = objects


func register_inactive_objects(objects: Array[Node2D]) -> void:
	_objects_registered = true
	objects_that_start_deactivated = objects


func _wait_for_objects_registration() -> void:
	while not _objects_registered:
		await get_tree().process_frame


func _change_object_power(objects: Array[Node2D], power_state: bool) -> void:
	for object in objects:
		object.change_power(power_state)
