extends CanvasLayer

signal back_pressed

@onready var beep_check: CheckBox = %BeepCheck
@onready var screenshake_check = %ScreenshakeCheck
@onready var window_check = $%WindowCheck
@onready var back_button = $%BackButton
@onready var sound_slider = $%SoundSlider
@onready var music_slider = $%MusicSlider
@onready var master_slider = $%MasterSlider
@onready var animation_player = $AnimationPlayer as AnimationPlayer

func _ready():
	GameState.state.progression.options_visited = true
	beep_check.toggled.connect(on_beep_check_toggled)
	window_check.toggled.connect(on_window_check_toggled)
	screenshake_check.toggled.connect(on_screenshake_check_toggled)
	back_button.pressed.connect(on_back_button_pressed)
	sound_slider.value_changed.connect(on_audio_slider_changed.bind("Sounds"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("Music"))
	master_slider.value_changed.connect(on_audio_slider_changed.bind("Master"))
	update_display()

func update_display():
	master_slider.value = get_bus_volume_percent("Master")
	sound_slider.value = get_bus_volume_percent("Sounds")
	music_slider.value = get_bus_volume_percent("Music")
	screenshake_check.set_pressed_no_signal(GameState.state.options.screenshake)
	beep_check.set_pressed_no_signal(GameState.state.options.heart_beep)

func get_bus_volume_percent(bus_name: String):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	GameState.save_volume_level(bus_name, percent)

func on_audio_slider_changed(value: float, bus_name: String):	
	set_bus_volume_percent(bus_name, value)

func on_screenshake_check_toggled(truth: bool):
	AudioManager.play_ui_click()
	GameState.toggle_screenshake(truth)
	if truth:
		GlobalCamera.add_trauma(0.125)

func on_window_check_toggled(truth: bool):	
	AudioManager.play_ui_click()
	if !truth:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func on_beep_check_toggled(truth: bool):
	AudioManager.play_ui_click()
	GameState.toggle_beep(truth)


func on_back_button_pressed():
	back_pressed.emit()
	exit()

func enter():
	visible = true
	animation_player.play("enter")

func exit():
	animation_player.play_backwards("enter")
	await animation_player.animation_finished
	visible = false
