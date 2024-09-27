extends CanvasLayer

const ENTER_SPEED_SCALE = 2.2
const HALF_WINDOW_SIZE = Vector2(640 , 360)

@export var tester: Node2D

@onready var animation_player = %AnimationPlayer
var options_instance
var is_closing = false
var viewing_options = false
var options_scene = preload("res://Scenes/UI/options_menu.tscn")

func _ready():
	#print("hi there")
	AudioManager.play_ui_click()
	FlowController.pause_game()
	animation_player.speed_scale = ENTER_SPEED_SCALE
	animation_player.play("enter")
	transform = GlobalCamera.transform
	var scaler = Vector2.ONE / GlobalCamera.zoom
	offset = GlobalCamera.get_camera_offset() - HALF_WINDOW_SIZE * scaler
	scale = scaler
	SharedPlayerManager.disable_ui()
	await animation_player.animation_finished
#	GlobalCamera.add_trauma(0.5)
	$%ResumeButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		if viewing_options:
			if options_instance != null:
				AudioManager.play_ui_click()
				options_instance.on_back_button_pressed()
		else:
			AudioManager.play_ui_click()
			close()
		get_tree().root.set_input_as_handled()
	

func close():
	#print("bye there")
	if is_closing: return
	is_closing = true
	animation_player.play_backwards("enter")
	await animation_player.animation_finished
	SharedPlayerManager.enable_ui()
	FlowController.unpause_game()
	queue_free()


func on_play_pressed():
	AudioManager.play_ui_click()
	close()

func on_options_pressed():
	AudioManager.play_ui_click()
	animation_player.play_backwards("enter_2")
	viewing_options = true
	await get_tree().create_timer(0.5).timeout
	if options_instance == null:
		options_instance = options_scene.instantiate()
		options_instance.transform = transform
		add_child(options_instance)
		options_instance.animation_player.speed_scale = 2
		options_instance.back_pressed.connect(on_options_closed)
	options_instance.enter()
	

func on_quit_pressed():
	AudioManager.play_ui_click()
	ScreenTransition.transition()
	animation_player.play_backwards("enter")
	FlowController.pause_game()
	await get_tree().create_timer(1.1).timeout
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
	FlowController.stop_level()

func on_options_closed():
	AudioManager.play_ui_click()
	await get_tree().create_timer(0.5).timeout
	viewing_options = false
	animation_player.play("enter_2")
