extends Node2D

const SPAWN_DELAY = 1

func _enter_tree() -> void:
	await get_tree().create_timer(SPAWN_DELAY).timeout
	FlowController.start_level()
