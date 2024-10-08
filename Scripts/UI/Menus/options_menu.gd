extends CanvasLayer

signal back_pressed

const TRAUMA_AMOUNT := 0.125
const ENTER_ANIMATION := "enter"

@onready var beep_check: CheckBox = %BeepCheck
@onready var screenshake_check: CheckBox = %ScreenshakeCheck
@onready var window_check: CheckBox = %WindowCheck
@onready var back_button: Button = %BackButton
@onready var sound_slider: Slider = %SoundSlider
@onready var music_slider: Slider = %MusicSlider
@onready var master_slider: Slider = %MasterSlider
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	GameState.state.progression.options_visited = true
	beep_check.toggled.connect(on_beep_check_toggled)
	window_check.toggled.connect(on_window_check_toggled)
	screenshake_check.toggled.connect(on_screenshake_check_toggled)
	back_button.pressed.connect(on_back_button_pressed)
	sound_slider.value_changed.connect(on_audio_slider_changed.bind(g.SOUND_BUS))
	music_slider.value_changed.connect(on_audio_slider_changed.bind(g.MUSIC_BUS))
	master_slider.value_changed.connect(on_audio_slider_changed.bind(g.MASTER_BUS))
	update_display()

func update_display() -> void:
	master_slider.value = get_bus_volume_percent(g.MASTER_BUS)
	sound_slider.value = get_bus_volume_percent(g.SOUND_BUS)
	music_slider.value = get_bus_volume_percent(g.MUSIC_BUS)
	screenshake_check.set_pressed_no_signal(GameState.state.options.screenshake)
	beep_check.set_pressed_no_signal(GameState.state.options.heart_beep)

func get_bus_volume_percent(bus_name: String) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var volume_db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)

func set_bus_volume_percent(bus_name: String, percent: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var volume_db := linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	GameState.save_volume_level(bus_name, percent)

func on_audio_slider_changed(value: float, bus_name: String) -> void:	
	set_bus_volume_percent(bus_name, value)

func on_screenshake_check_toggled(enable: bool) -> void:
	AudioManager.play_ui_click()
	GameState.toggle_screenshake(enable)
	if enable:
		GlobalCamera.add_trauma(TRAUMA_AMOUNT)

func on_window_check_toggled(is_windowed: bool) -> void:	
	AudioManager.play_ui_click()
	if is_windowed:
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func on_beep_check_toggled(enable: bool) -> void:
	AudioManager.play_ui_click()
	GameState.toggle_beep(enable)

func on_back_button_pressed() -> void:
	back_pressed.emit()
	exit()

func enter() -> void:
	visible = true
	animation_player.play(ENTER_ANIMATION)

func exit() -> void:
	animation_player.play_backwards(ENTER_ANIMATION)
	await animation_player.animation_finished
	visible = false