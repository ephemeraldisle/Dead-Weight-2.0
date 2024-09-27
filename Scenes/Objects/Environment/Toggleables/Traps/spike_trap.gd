extends Toggleable
class_name SpikeTrap

signal finished_charging
signal finished_discharging

const FULL_FRAME_PROGRESS := 1.0
const LIGHT_FADE_TIME := 1.0
const CHARGE_UP_ANIMATION := "activate"
const ACTIVE_ANIMATION := "activeloop"
const DEACTIVATE_ANIMATION := "deactivate"

@export var always_on := true
@export var sound_enabled := false
@export var off_time: float = 5
@export var on_time: float = 2
@export var initial_delay: float = 0.5

var _looping := false
var _deactivated_frame := 7

@onready var damaging_zone: Area2D = $DamagingZone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var charge_sound: AudioStreamPlayer2D = %ChargeSound
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var loop_sound: AudioStreamPlayer2D = %LoopSound
@onready var discharge_sound: AudioStreamPlayer2D = %DischargeSound 
@onready var light: PointLight2D = %Light
@onready var pressure_activator: Area2D = $PressureActivator
@onready var timer_component: Timer = $TimerComponent



func _ready():
	animated_sprite_2d.set_frame_and_progress(_deactivated_frame, FULL_FRAME_PROGRESS)
	super()
	
	timer_component.timeout.connect(on_timer_timeout)
	pressure_activator.pressure_activated.connect(on_pressure_activated)
	
	if always_on and power_controller.powered:
		activate(true)
	elif off_time > 0 and power_controller.powered:
		await get_tree().create_timer(initial_delay, false, true).timeout
		eject_spikes()
	else:
		deactivate(true)


func eject_spikes() -> void:
	if power_controller.powered:
		await get_tree().create_timer(initial_delay, false, true).timeout
		charge_up()
		await finished_charging
		activate()
		await get_tree().create_timer(on_time, false, true).timeout
		deactivate()


func charge_up():
	light.visible = true
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, LIGHT_OPACITY, FULL_OPACITY, LIGHT_FADE_TIME)
	animated_sprite_2d.play(CHARGE_UP_ANIMATION)
	await animated_sprite_2d.animation_finished
	finished_charging.emit()


func activate(_instant: bool = false) -> void:
	light.visible = true
	light.color.a = FULL_OPACITY
	animated_sprite_2d.play(ACTIVE_ANIMATION)
	if sound_enabled:
		loop_sound.play()
	damaging_zone.monitoring = true
	_looping = true
	activated.emit()


func deactivate(instant: bool = false) -> void:
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, LIGHT_OPACITY, NO_OPACITY, INSTANT_TIME if instant else LIGHT_FADE_TIME)
	animated_sprite_2d.play(DEACTIVATE_ANIMATION)
	if instant:
		animated_sprite_2d.set_frame_and_progress(_deactivated_frame, FULL_FRAME_PROGRESS)
	damaging_zone.monitoring = false
	_looping = false
	if sound_enabled:
		loop_sound.stop()
	deactivated.emit()


func make_invisible(instant: bool = false) -> void:
	var tween_time = INSTANT_TIME if instant else FADE_TIME
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, LIGHT_POWER, NO_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, DB_PROPERTY, SILENT_DB_LEVEL, tween_time).from_current()
	tween.tween_property(self, OPACITY, NO_OPACITY, tween_time).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween_time = INSTANT_TIME if instant else FADE_TIME
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, LIGHT_POWER, FULL_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, DB_PROPERTY, NORMAL_DB, tween_time).from_current()
	tween.tween_property(self, OPACITY, FULL_OPACITY, tween_time).from_current()
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
	if powered and always_on:
		activate()
	else:
		deactivate()


func on_timer_timeout() -> void:
	if power_controller.powered:
		eject_spikes()


func on_pressure_activated() -> void:
	if power_controller.powered:
		eject_spikes()
