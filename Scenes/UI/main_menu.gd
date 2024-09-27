extends CanvasLayer

const OPTIONS_ANIMATION_TIME = 0.5 
const PLAY_PRESSED_DELAY = 0.05
const TRANSITION_DELAY = 1.1

@export var tester: Node2D

@onready var animation_player = %AnimationPlayer
@onready var rumble_looper = $RumbleLooper


var options_scene = preload("res://Scenes/UI/options_menu.tscn")
#var introduction = preload("res://Scenes/Levels/game_intro_scene.tscn")
var options_instance

func _ready():
	FlowController.unpause_game()
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)	
	GlobalCamera.follow_node(tester)

func on_play_pressed():
	AudioManager.play_ui_click()
	await get_tree().create_timer(PLAY_PRESSED_DELAY).timeout
#	ScreenTransition.transition()
	animation_player.play_backwards("enter")
#	await ScreenTransition.transitioned_halfway
#	if !GameState.introduction_watched:
#		var intro = introduction.instantiate()
#		add_child(intro)
#	else:
	ScreenTransition.transition()
	await get_tree().create_timer(TRANSITION_DELAY).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")
#	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")


func on_options_pressed():
	AudioManager.play_ui_click()
	animation_player.play_backwards("enter")
	await get_tree().create_timer(OPTIONS_ANIMATION_TIME).timeout
	if options_instance == null:
		options_instance = options_scene.instantiate()
		add_child(options_instance)
		options_instance.back_pressed.connect(on_options_closed)
	
	options_instance.enter()
	

func on_quit_pressed():
	AudioManager.play_ui_click()
	ScreenTransition.transition()
	await get_tree().create_timer(TRANSITION_DELAY).timeout
	get_tree().quit()

func on_options_closed():
	AudioManager.play_ui_click()	
	await get_tree().create_timer(OPTIONS_ANIMATION_TIME).timeout
	animation_player.play("enter")

func start_playing_audio():
	if rumble_looper.playing:
		return
	rumble_looper.play()
