extends Node2D
class_name Toggleable

signal activated
signal deactivated
signal made_invisible
signal made_visible

const FADE_TIME := 0.4
const INSTANT_TIME := 0.01
const NO_OPACITY := 0
const FULL_OPACITY := 1
const NO_LIGHT_POWER := 0
const FULL_LIGHT_POWER := 1
const SILENT_DB_LEVEL := -80
const NORMAL_DB := 0
const OPACITY := "modulate:a"
const DB_PROPERTY := "volume_db"
const LIGHT_OPACITY := "color:a"
const LIGHT_POWER := "energy"

@onready var power_controller = $PowerController as PowerController


func _ready() -> void:
	power_controller.power_changed.connect(on_power_changed)


func activate(_instant: bool = false) -> void:
	activated.emit()


func deactivate(_instant: bool = false) -> void:
	deactivated.emit()


func make_invisible(_instant: bool = false) -> void:
	made_invisible.emit()


func make_visible(_instant: bool = false) -> void:
	made_visible.emit()


func change_power(powered: bool) -> void:
	if powered:
		power_controller.power_on()
	else:
		power_controller.power_off()


func on_power_changed(_powered: bool) -> void:
	pass
