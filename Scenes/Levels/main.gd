extends Node2D

const SPAWN_DELAY = 1

func _enter_tree() -> void:
	await get_tree().create_timer(1).timeout
	FlowController.start_level()
