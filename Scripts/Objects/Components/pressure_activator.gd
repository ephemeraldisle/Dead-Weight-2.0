extends Area2D

signal pressure_activated

const OFF_TIME_NAME := "off_time"
const PRESSURE_DELAY := 1.0

@onready var parent = get_parent() as Toggleable

var _activatable := true

func _ready() -> void:
	if parent.get(OFF_TIME_NAME):
		if parent.off_time > 0:
			return
	parent.deactivated.connect(make_activatable)
	await get_tree().create_timer(PRESSURE_DELAY, false, true).timeout
	_on_body_entered(self)
	
func make_activatable() -> void:
	_activatable = true

func _on_body_entered(_body: Node2D) -> void:
	if not _activatable: return
	_activatable = false
	pressure_activated.emit()
