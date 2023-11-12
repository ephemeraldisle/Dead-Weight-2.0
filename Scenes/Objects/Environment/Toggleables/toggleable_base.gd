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

func activate(instant: bool = false) -> void:
	activated.emit()

func deactivate(instant: bool = false) -> void:
	deactivated.emit()

func make_invisible(instant: bool = false) -> void:
	made_invisible.emit()

func make_visible(instant: bool = false) -> void:
	made_visible.emit()

func change_power(powered: bool) -> void:
	if powered:
		power_controller.power_on()
	else:
		power_controller.power_off()

func on_power_changed(powered: bool) -> void:
	pass
