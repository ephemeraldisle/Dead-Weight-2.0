extends Node

const PAUSE_MENU_SCENE := preload("res://Scenes/UI/pause_menu.tscn")

var game_running := true

func start_level() -> void:
	SharedPlayerManager.spawn_player()
	SharedPlayerManager.enable_ui(true)

func stop_level() -> void:
	SharedPlayerManager.despawn_player()
	SharedPlayerManager.disable_ui()

func _unhandled_input(event: InputEvent) -> void:
	if game_running and event.is_action_pressed(g.PAUSE_BUTTON):
		get_tree().root.set_input_as_handled()
		var pause_menu := PAUSE_MENU_SCENE.instantiate()
		add_child(pause_menu)

func pause_game() -> void:
	get_tree().paused = true

func unpause_game() -> void:
	get_tree().paused = false