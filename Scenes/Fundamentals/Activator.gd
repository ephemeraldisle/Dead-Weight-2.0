extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.get("power_controller"):
		body.power_controller.activate()

func _on_body_exited(body: Node2D) -> void:
	if body.get("power_controller"):
		body.power_controller.deactivate()
