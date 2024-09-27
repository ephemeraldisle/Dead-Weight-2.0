extends Node

var pause_menu_scene = preload("res://Scenes/UI/pause_menu.tscn")

var game_running = true

func start_level() -> void:
	SharedPlayerManager.spawn_player()
	SharedPlayerManager.enable_ui(true)

func stop_level() -> void:
	SharedPlayerManager.despawn_player()
	SharedPlayerManager.disable_ui()

func _unhandled_input(event) -> void:
	if game_running:
		if event.is_action_pressed("pause"):
			get_tree().root.set_input_as_handled()
			var pause = pause_menu_scene.instantiate()
			add_child(pause)

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false
