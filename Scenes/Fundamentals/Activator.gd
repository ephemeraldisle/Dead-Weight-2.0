extends Area2D

const ACTIVATION_CONTROLLER_NAME = "power_controller"

func _on_body_entered(body: Node2D) -> void:
	if body.get(ACTIVATION_CONTROLLER_NAME):
		body.power_controller.activate()

func _on_body_exited(body: Node2D) -> void:
	if body.get(ACTIVATION_CONTROLLER_NAME):
		body.power_controller.deactivate()
