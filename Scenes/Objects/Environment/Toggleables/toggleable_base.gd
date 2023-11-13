extends Node2D
class_name Toggleable

const FADE_TIME = 0.4

signal activated
signal deactivated
signal made_invisible
signal made_visible

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
