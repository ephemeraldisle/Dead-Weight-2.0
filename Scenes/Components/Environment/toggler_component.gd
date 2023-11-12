extends Node2D
class_name Toggler
# The assumption here is that we start "on" with toggled as "true."

signal toggled_from_save

var objects_that_start_activated: Array[Node2D]
var objects_that_start_deactivated: Array[Node2D]
var toggled = true
var objects_registered = false

@onready var save_data = $SaveData as SaveData

func _ready() -> void:
	while objects_registered == false:
		await get_tree().process_frame
	check_save_data()
	save_data.save_updated.connect(check_save_data)

func set_off() -> void:
	toggle_off()
	save_data.update_data("toggled", false)
	
func set_on() -> void:
	toggle_on()
	save_data.update_data("toggled", true)
	
	
func toggle_off() -> void:
	toggled = false
	if objects_that_start_activated.size() > 0:
		for object in objects_that_start_activated:
			object.change_power(false)
	if objects_that_start_deactivated.size() > 0:
		for object in objects_that_start_deactivated:
			object.change_power(true)

func toggle_on() -> void:
	toggled = true
	if objects_that_start_activated.size() > 0:
		for object in objects_that_start_activated:
			object.change_power(true)
	if objects_that_start_deactivated.size() > 0:
		for object in objects_that_start_deactivated:
			object.change_power(false)

func check_save_data() -> void:
	if !save_data.get_data("toggled"):
		toggle_off()
	else:
		toggle_on()
	toggled_from_save.emit()

func register_active_objects(objects: Array) -> void:
	objects_registered = true
	objects_that_start_activated = objects

func register_inactive_objects(objects: Array) -> void:
	objects_registered = true
	objects_that_start_deactivated = objects
