extends CanvasLayer

const ENTER_SPEED_SCALE := 2.2
const OPTIONS_SPEED_SCALE := 2.0
const OPTIONS_SCENE := preload("res://Scenes/UI/options_menu.tscn")
const MAIN_MENU_SCENE := "res://Scenes/UI/main_menu.tscn"
const ENTER_ANIMATION := "enter"
const ENTER_2_ANIMATION := "enter_2"
const OPTIONS_TRANSITION_TIME := 0.5
const QUIT_TRANSITION_TIME := 1.1

@export var tester: Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

var options_instance: Node
var is_closing := false
var viewing_options := false

func _ready() -> void:
	AudioManager.play_ui_click()
	FlowController.pause_game()
	_setup_animation()
	_setup_transform()
	SharedPlayerManager.disable_ui()
	await animation_player.animation_finished
	_connect_buttons()

func _setup_animation() -> void:
	animation_player.speed_scale = ENTER_SPEED_SCALE
	animation_player.play(ENTER_ANIMATION)

func _setup_transform() -> void:
	transform = GlobalCamera.transform
	var scaler := Vector2.ONE / GlobalCamera.zoom
	offset = GlobalCamera.get_camera_offset() - g.HALF_WINDOW_SIZE * scaler
	scale = scaler

func _connect_buttons() -> void:
	resume_button.pressed.connect(on_play_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(g.PAUSE_BUTTON):
		if viewing_options and options_instance != null:
			AudioManager.play_ui_click()
			options_instance.on_back_button_pressed()
		else:
			AudioManager.play_ui_click()
			close()
		get_tree().root.set_input_as_handled()

func close() -> void:
	if is_closing:
		return
	is_closing = true
	animation_player.play_backwards(ENTER_ANIMATION)
	await animation_player.animation_finished
	SharedPlayerManager.enable_ui()
	FlowController.unpause_game()
	queue_free()

func on_play_pressed() -> void:
	AudioManager.play_ui_click()
	close()

func on_options_pressed() -> void:
	AudioManager.play_ui_click()
	animation_player.play_backwards(ENTER_2_ANIMATION)
	viewing_options = true
	await get_tree().create_timer(OPTIONS_TRANSITION_TIME).timeout
	if options_instance == null:
		options_instance = OPTIONS_SCENE.instantiate()
		options_instance.transform = transform
		add_child(options_instance)
		options_instance.animation_player.speed_scale = OPTIONS_SPEED_SCALE
		options_instance.back_pressed.connect(on_options_closed)
	options_instance.enter()

func on_quit_pressed() -> void:
	AudioManager.play_ui_click()
	ScreenTransition.transition()
	animation_player.play_backwards(ENTER_ANIMATION)
	FlowController.pause_game()
	await get_tree().create_timer(QUIT_TRANSITION_TIME).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
	FlowController.stop_level()

func on_options_closed() -> void:
	AudioManager.play_ui_click()
	await get_tree().create_timer(OPTIONS_TRANSITION_TIME).timeout
	viewing_options = false
	animation_player.play(ENTER_2_ANIMATION)