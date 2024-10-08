extends CanvasLayer

const OPTIONS_ANIMATION_TIME := 0.5 
const PLAY_PRESSED_DELAY := 0.05
const TRANSITION_DELAY := 1.1
const MAIN_SCENE_PATH := "res://Scenes/Levels/main.tscn"
const OPTIONS_SCENE_PATH := "res://Scenes/UI/options_menu.tscn"
const ENTER_ANIMATION := "enter"
const OPTIONS_SCENE := preload(OPTIONS_SCENE_PATH)
#const INTRODUCTION_SCENE = preload("res://Scenes/Levels/game_intro_scene.tscn")

@export var tester: Node2D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var rumble_looper: AudioStreamPlayer = $RumbleLooper
@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

var options_instance: Node

func _ready() -> void:
	FlowController.unpause_game()
	play_button.pressed.connect(on_play_pressed)
	options_button.pressed.connect(on_options_pressed)
	quit_button.pressed.connect(on_quit_pressed)	
	GlobalCamera.follow_node(tester)

func on_play_pressed() -> void:
	AudioManager.play_ui_click()
	await get_tree().create_timer(PLAY_PRESSED_DELAY).timeout
#	ScreenTransition.transition()
	animation_player.play_backwards(ENTER_ANIMATION)
#	await ScreenTransition.transitioned_halfway
#	if !GameState.introduction_watched:
#		var intro = INTRODUCTION_SCENE.instantiate()
#		add_child(intro)
#	else:
	ScreenTransition.transition()
	await get_tree().create_timer(TRANSITION_DELAY).timeout
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)

func on_options_pressed() -> void:
	AudioManager.play_ui_click()
	animation_player.play_backwards(ENTER_ANIMATION)
	await get_tree().create_timer(OPTIONS_ANIMATION_TIME).timeout
	if options_instance == null:
		options_instance = OPTIONS_SCENE.instantiate()
		add_child(options_instance)
		options_instance.back_pressed.connect(on_options_closed)
	
	options_instance.enter()

func on_quit_pressed() -> void:
	AudioManager.play_ui_click()
	ScreenTransition.transition()
	await get_tree().create_timer(TRANSITION_DELAY).timeout
	get_tree().quit()

func on_options_closed() -> void:
	AudioManager.play_ui_click()	
	await get_tree().create_timer(OPTIONS_ANIMATION_TIME).timeout
	animation_player.play(ENTER_ANIMATION)

func start_playing_audio() -> void:
	if not rumble_looper.playing:
		rumble_looper.play()
