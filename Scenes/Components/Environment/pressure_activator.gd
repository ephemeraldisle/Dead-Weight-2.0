extends Area2D

signal pressure_activated

@onready var parent = get_parent() as Toggleable

var _activatable := true

func _ready() -> void:
	if parent.get("off_time"):
		if parent.off_time > 0:
			return
			
	parent.deactivated.connect(make_activatable)
	await get_tree().create_timer(1).timeout
	_on_body_entered(self)
func make_activatable() -> void:
	_activatable = true

func _on_body_entered(body: Node2D) -> void:
	if not _activatable: return
	_activatable = false
	pressure_activated.emit()
