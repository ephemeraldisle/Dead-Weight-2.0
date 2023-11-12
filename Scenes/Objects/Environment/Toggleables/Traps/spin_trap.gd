extends Toggleable

signal finished_charging
signal finished_discharging

const DEACTIVATED_FRAME = 4
const LIGHT_FADE_TIME = 1.0

@export var always_on: bool = true
@export var sound_enabled = false
@export var off_time: float = 5
@export var on_time: float = 2
@export var initial_delay: float = 0.5

@onready var damaging_zone = $DamagingZone
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var charge_sound = %ChargeSound as AudioStreamPlayer2D
@onready var fire_sound = %FireSound as AudioStreamPlayer2D
@onready var loop_sound = %LoopSound as AudioStreamPlayer2D
@onready var discharge_sound = %DischargeSound as AudioStreamPlayer2D
@onready var light: PointLight2D = %Light
@onready var pressure_zone: Area2D = %PressureZone

@onready var pressure_activator: Area2D = $PressureActivator
@onready var timer_component: Timer = $TimerComponent

var looping = false

func _ready():
	animated_sprite_2d.set_frame_and_progress(DEACTIVATED_FRAME, 1)
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
	light_tween.tween_property(light, "color:a", 1, LIGHT_FADE_TIME)
	animated_sprite_2d.play("activate")	
	await animated_sprite_2d.animation_finished
	finished_charging.emit()


func activate(instant: bool = false) -> void:
	light.visible = true
	light.color.a = 1
	animated_sprite_2d.play("activeloop")
	if sound_enabled: 
		loop_sound.play()
	damaging_zone.monitoring = true
	looping = true
	activated.emit()


func deactivate(instant: bool = false) -> void:
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, "color:a", 0, 0.01 if instant else LIGHT_FADE_TIME)
	animated_sprite_2d.play("deactivate")
	if instant:
		animated_sprite_2d.set_frame_and_progress(DEACTIVATED_FRAME, 1)
	damaging_zone.monitoring = false
	looping = false
	if sound_enabled:
		loop_sound.stop()
	deactivated.emit()

func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(loop_sound, "volume_db", -80, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_invisible.emit()
	
func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 1, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(loop_sound, "volume_db", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()
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
