extends CanvasLayer

const BARS_PER_BATTERY = 4
const MINIMUM_ANIMATION_FRAMES = 20


@export var energy_manager: Node

#var energy_manager = {
#	"current_energy": 5.7,
#	"current_bars": 5,
#	"current_batteries": 4,
#}

var _current_batteries: Array
var _active_battery

var _previous_percent := 1.0
var _current_percent := 1.0
var _animating = false
var _power_on_ticks: int = 0


#@onready var _power_indicator: TextureRect = %PowerIndicator
@onready var _power_indicator_animator: AnimationPlayer = %PowerIndicatorAnimator
@onready var _battery_children = %BatteryHolder.get_children()
@onready var vision_controller: MarginContainer = $VisionController


func _ready() -> void:
	energy_manager.bars_changed.connect(_update_battery_texture_frames)
	_update_available_batteries()
	_update_battery_texture_frames()


func _physics_process(_delta: float) -> void:
	if _active_battery == null:
		return
	_current_percent = clamp(energy_manager.current_energy - energy_manager.current_bars, 0, 1)
	_update_progress_bar_fill()
	if _current_percent < _previous_percent:
		_power_on_ticks = 0
		_animation_on()
	elif _animating:
		_power_on_ticks += 1
		if _power_on_ticks >= MINIMUM_ANIMATION_FRAMES:
			_animation_off()
			_power_on_ticks = 0
	_previous_percent = _current_percent


func _update_available_batteries() -> void:
	var available_batteries = []
	for i in energy_manager.current_batteries:
		_battery_children[i].visible = true
		available_batteries.push_front(_battery_children[i])
	_current_batteries = available_batteries


func _update_battery_texture_frames() -> void:
	var available_bars = energy_manager.current_bars
#	print(available_bars)
	for battery in _current_batteries:
		if available_bars >= 0:
			if available_bars >= BARS_PER_BATTERY:
				battery.texture.current_frame = BARS_PER_BATTERY
				battery.change_progress_bar_visibility(false)
			else:
				battery.texture.current_frame = available_bars
				_active_battery = battery
				battery.change_progress_bar_visibility(true)
				battery.adjust_progress_bar_position(available_bars)
			available_bars -= BARS_PER_BATTERY
		else:
			battery.texture.current_frame = 0
			battery.change_progress_bar_visibility(false)

func _update_progress_bar_fill() -> void:
	_active_battery.adjust_progress_bar_fill(_current_percent)


func _animation_on():
	if not _animating:
		for battery in _current_batteries:
			battery.sparks.emitting = true
		_animating = true
		_power_indicator_animator.play("poweron")


func _animation_off():
	_animating = false
	_power_indicator_animator.play_backwards("poweroff")
	for battery in _current_batteries:
		battery.sparks.emitting = false


func fade_visibility(vis: bool, fade_time: float) -> void:
	var tween = create_tween()	
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if vis == false:
		tween.tween_property(vision_controller, "modulate:a", 0.0, fade_time).from(1.0)
	else:
		tween.tween_property(vision_controller, "modulate:a", 1.0, fade_time).from(0.0)	
