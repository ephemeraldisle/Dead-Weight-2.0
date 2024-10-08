extends Toggleable
class_name LaserTrap

signal finished_charging
signal finished_discharging

const SOUND_FADE_TIME := FADE_TIME * 2.0
const OFF_TIME_OVERRIDE := -1
const LIGHT_CHARGE_TIME := 1
const CHARGING_ANIMATION := "Activate"
const CHARGE_SOUND_TIME := 1.15
const LOOPING_SOUND_TIME := 3
const DISCHARGE_SOUND_TIME := 0.25


@export var always_on = false
@export var sound_enabled = false
@export var off_time: float = 5
@export var on_time: float = 2
@export var initial_delay: float = 0.5

var _looping = false
var _initializing = false
var _active_animation := "Active"
var _deactivate_animation := "Deactivate"
var _off_animation := "Inactive"



@onready var damaging_zone: Area2D = $DamagingZone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var charge_sound: AudioStreamPlayer2D = %ChargeSound
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var loop_sound: AudioStreamPlayer2D = %LoopSound
@onready var discharge_sound: AudioStreamPlayer2D = %DischargeSound
@onready var light: PointLight2D = %Light
@onready var timer_component: Timer = $TimerComponent
@onready var wall: StaticBody2D = %Wall



func _ready() -> void:
	if always_on:
		off_time = OFF_TIME_OVERRIDE
	super()
	timer_component.timeout.connect(on_timer_timeout)
	if not power_controller.powered:
		deactivate(true)
	elif always_on:
		activate(true)
	else:
		_initializing = true
		await get_tree().create_timer(initial_delay, false, true).timeout
		fire_laser()


func fire_laser() -> void:
	if power_controller.powered:
		charge_up()
		await finished_charging
		activate()
		await get_tree().create_timer(on_time, false, true).timeout
		charge_down()
		await finished_discharging
		deactivate()


func charge_up() -> void:
	light.visible = true
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.FULL_OPACITY, LIGHT_CHARGE_TIME)
	if sound_enabled:
		synced_sound_coroutine()
	animated_sprite_2d.play(CHARGING_ANIMATION)
	await animated_sprite_2d.animation_finished
	finished_charging.emit()


func activate(instant: bool = false) -> void:
	light.visible = true
	light.color.a = g.FULL_OPACITY
	animated_sprite_2d.play(_active_animation)

	if instant and sound_enabled:
		loop_sound.play()

	damaging_zone.monitoring = true
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, true)
	_looping = true
	activated.emit()


func charge_down() -> void:
	animated_sprite_2d.play(_deactivate_animation)
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.NO_OPACITY, LIGHT_CHARGE_TIME)
	damaging_zone.set_deferred(MONITORING, false)
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)
	await animated_sprite_2d.animation_finished
	finished_discharging.emit()


func deactivate(_instant: bool = false) -> void:
	animated_sprite_2d.play(_off_animation)
	light.visible = false
	damaging_zone.set_deferred(MONITORING, false)
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)
	_looping = false
	if sound_enabled:
		loop_sound.stop()
	_initializing = false
	if power_controller.powered:
		deactivated.emit()


func synced_sound_coroutine() -> void:
	var remaining_time = on_time
	charge_sound.play()
	await get_tree().create_timer(CHARGE_SOUND_TIME, false, true).timeout
	charge_sound.stop()
	fire_sound.play()
	if remaining_time > LOOPING_SOUND_TIME:
		await get_tree().create_timer(LOOPING_SOUND_TIME, false, true).timeout
		remaining_time -= LOOPING_SOUND_TIME
		loop_sound.play()
		await get_tree().create_timer(remaining_time, false, true).timeout
		loop_sound.stop()
	else:
		await get_tree().create_timer(remaining_time, false, true).timeout
	discharge_sound.play()
	await get_tree().create_timer(DISCHARGE_SOUND_TIME, false, true).timeout
	fire_sound.stop()


func make_invisible(instant: bool = false) -> void:
	var tween_time = g.INSTANT_TIME if instant else FADE_TIME
	var sound_tween_time = g.INSTANT_TIME if instant else SOUND_FADE_TIME
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER,tween_time).from_current()
	tween.tween_property(loop_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(charge_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(fire_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(discharge_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, tween_time).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween_time = g.INSTANT_TIME if instant else FADE_TIME
	var sound_tween_time = g.INSTANT_TIME if instant else SOUND_FADE_TIME
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.FULL_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, g.DB_PROPERTY, g.NORMAL_DB, sound_tween_time).from_current()
	tween.tween_property(charge_sound, g.DB_PROPERTY, g.NORMAL_DB, sound_tween_time).from_current()
	tween.tween_property(fire_sound, g.DB_PROPERTY, g.NORMAL_DB, sound_tween_time).from_current()
	tween.tween_property(discharge_sound, g.DB_PROPERTY, g.NORMAL_DB, sound_tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, tween_time).from_current()
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
#	print("%s power turned %s" % [get_path(), powered])
	if powered and always_on:
		activate()
	elif not _initializing:
		deactivate()


func on_timer_timeout() -> void:
	if power_controller.powered:
		fire_laser()
