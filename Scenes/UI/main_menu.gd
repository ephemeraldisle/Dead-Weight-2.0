extends CanvasLayer

var options_scene = preload("res://Scenes/UI/options_menu.tscn")
#var introduction = preload("res://Scenes/Levels/game_intro_scene.tscn")
@onready var animation_player = %AnimationPlayer
var options_instance
@onready var rumble_looper = $RumbleLooper
@export var tester: Node2D

func _ready():
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)	
	GlobalCamera.follow_node(tester)

func on_play_pressed():
	AudioManager.play_ui_click()
	await get_tree().create_timer(0.05).timeout
#	ScreenTransition.transition()
	animation_player.play_backwards("enter")
#	await ScreenTransition.transitioned_halfway
#	if !GameState.introduction_watched:
#		var intro = introduction.instantiate()
#		add_child(intro)
#	else:
	ScreenTransition.transition()
	await get_tree().create_timer(1.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")
#	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")


func on_options_pressed():
	AudioManager.play_ui_click()
	animation_player.play_backwards("enter")
	await get_tree().create_timer(0.5).timeout
	if options_instance == null:
		options_instance = options_scene.instantiate()
		add_child(options_instance)
		options_instance.back_pressed.connect(on_options_closed)
	
	options_instance.enter()
	

func on_quit_pressed():
	AudioManager.play_ui_click()
	ScreenTransition.transition()
	await get_tree().create_timer(1.1).timeout
	get_tree().quit()

func on_options_closed():
	AudioManager.play_ui_click()	
	await get_tree().create_timer(0.5).timeout
	animation_player.play("enter")

func start_playing_audio():
	if rumble_looper.playing:
		return
	rumble_looper.play()
