extends Toggleable
class_name Laser_Trap

signal finished_charging
signal finished_discharging

const SOUND_FADE_TIME = FADE_TIME * 2.0

@export var always_on = false
@export var sound_enabled = false
@export var off_time: float = 5
@export var on_time: float = 2
@export var initial_delay: float = 0.5

@onready var damaging_zone: Area2D = $DamagingZone
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var charge_sound = %ChargeSound as AudioStreamPlayer2D
@onready var fire_sound = %FireSound as AudioStreamPlayer2D
@onready var loop_sound = %LoopSound as AudioStreamPlayer2D
@onready var discharge_sound = %DischargeSound as AudioStreamPlayer2D
@onready var light: PointLight2D = %Light
@onready var timer_component: Timer = $TimerComponent

var looping = false


func _ready():
	super()
	timer_component.timeout.connect(on_timer_timeout)
	if not power_controller.powered:
		deactivate(true)
	elif always_on:
		activate(true)
	else:
		await get_tree().create_timer(initial_delay, false, true).timeout
		fire_laser()


func fire_laser() -> void:
	if power_controller.powered:
		await get_tree().create_timer(initial_delay, false, true).timeout
		charge_up()
		await finished_charging
		activate()
		await get_tree().create_timer(on_time, false, true).timeout
		charge_down()
		await finished_discharging
		deactivate()


func charge_up():
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, "color:a", 1, 1)
	if sound_enabled:
		synced_sound_coroutine()
	animated_sprite_2d.play("Activate")
	await animated_sprite_2d.animation_finished
	finished_charging.emit()


func activate(instant: bool = false) -> void:
	light.visible = true

	animated_sprite_2d.play("Active")

	if instant and sound_enabled:
		loop_sound.play()

	damaging_zone.monitoring = true
	looping = true
	activated.emit()


func charge_down():
	animated_sprite_2d.play("Deactivate")
	var light_tween = create_tween() as Tween
	light_tween.tween_property(light, "color:a", 0, 1)
	damaging_zone.monitoring = false
	await animated_sprite_2d.animation_finished
	finished_discharging.emit()


func deactivate(_instant: bool = false) -> void:
	animated_sprite_2d.play("Inactive")
	light.visible = false
	damaging_zone.monitoring = false
	looping = false
	if sound_enabled:
		loop_sound.stop()
	deactivated.emit()


func synced_sound_coroutine():
	var remaining_time = on_time
	charge_sound.play()
	await get_tree().create_timer(1.15, false, true).timeout
	charge_sound.stop()
	fire_sound.play()
	if remaining_time > 3:
		await get_tree().create_timer(3, false, true).timeout
		remaining_time -= 3
		loop_sound.play()
		await get_tree().create_timer(remaining_time, false, true).timeout
		loop_sound.stop()
	else:
		await get_tree().create_timer(remaining_time, false, true).timeout
	discharge_sound.play()
	await get_tree().create_timer(0.25, false, true).timeout
	fire_sound.stop()


func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(loop_sound, "volume_db", -80, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(charge_sound, "volume_db", -80, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(fire_sound, "volume_db", -80, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(discharge_sound, "volume_db", -80, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 1, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(loop_sound, "volume_db", 0, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(charge_sound, "volume_db", 0, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(fire_sound, "volume_db", 0, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(discharge_sound, "volume_db", 0, 0.01 if instant else SOUND_FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
	if powered and always_on:
		activate()
	else:
		deactivate()


func on_timer_timeout():
	if power_controller.powered:
		fire_laser()
