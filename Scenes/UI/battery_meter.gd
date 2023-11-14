extends CanvasLayer

const BARS_PER_BATTERY = 4
const MINIMUM_ANIMATION_FRAMES = 20


@export var energy_manager: Node

#var energy_manager = {
#	"current_energy": 5.7,
#	"current_bars": 5,
#	"current_batteries": 4,
#}

var current_batteries
var active_battery

var previous_percent := 1.0
var current_percent := 1.0
var animating = false
var power_on_ticks: int = 0


@onready var power_indicator: TextureRect = %PowerIndicator
@onready var power_indicator_animator: AnimationPlayer = %PowerIndicatorAnimator
@onready var sparks: GPUParticles2D = $MarginContainer/BatteryHolder/Battery0/Sparks
@onready var battery_children = %BatteryHolder.get_children()


func _ready() -> void:
	energy_manager.bars_changed.connect(_update_battery_texture_frames)
	_update_available_batteries()
	_update_battery_texture_frames()


func _physics_process(_delta: float) -> void:
	current_percent = clamp(energy_manager.current_energy - energy_manager.current_bars, 0, 1)
	_update_progress_bar_fill()
	if current_percent < previous_percent:
		power_on_ticks = 0
		_animation_on()
	elif animating:
		power_on_ticks += 1
		if power_on_ticks >= MINIMUM_ANIMATION_FRAMES:
			_animation_off()
			power_on_ticks = 0
	previous_percent = current_percent


func _update_available_batteries() -> void:
	var available_batteries = []
	for i in energy_manager.current_batteries:
		battery_children[i].visible = true
		available_batteries.push_front(battery_children[i])
	current_batteries = available_batteries


func _update_battery_texture_frames() -> void:
	var available_bars = energy_manager.current_bars
	for battery in current_batteries:
		if available_bars > 0:
			if available_bars >= BARS_PER_BATTERY:
				battery.texture.current_frame = BARS_PER_BATTERY
				battery.change_progress_bar_visibility(false)
			else:
				battery.texture.current_frame = available_bars
				active_battery = battery
				battery.change_progress_bar_visibility(true)
				battery.adjust_progress_bar_position(available_bars)
			available_bars -= BARS_PER_BATTERY
		else:
			battery.texture.current_frame = 0


func _update_progress_bar_fill() -> void:
	active_battery.adjust_progress_bar_fill(current_percent)


func _animation_on():
	if not animating:
		for battery in current_batteries:
			battery.sparks.emitting = true
		animating = true
		power_indicator_animator.play("poweron")


func _animation_off():
	animating = false
	power_indicator_animator.play_backwards("poweroff")
	for battery in current_batteries:
		battery.sparks.emitting = false
