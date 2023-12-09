extends CanvasLayer

var options_scene = preload("res://Scenes/UI/options_menu.tscn")
@onready var animation_player = %AnimationPlayer
var options_instance
@export var tester: Node2D
var is_closing = false
var viewing_options = false

func _ready():
	#print("hi there")
	AudioManager.play_ui_click()
	get_tree().paused = true
	animation_player.speed_scale = 2.2
	animation_player.play("enter")
	transform = GlobalCamera.transform
	var scaler = Vector2(1,1) / GlobalCamera.zoom
	offset = GlobalCamera.get_camera_offset() - Vector2(640, 360)*scaler
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
	get_tree().paused = false
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
	await get_tree().create_timer(1.1).timeout
	get_tree().paused = false
	FlowController.stop_level()
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func on_options_closed():
	AudioManager.play_ui_click()
	await get_tree().create_timer(0.5).timeout
	viewing_options = false
	animation_player.play("enter_2")
