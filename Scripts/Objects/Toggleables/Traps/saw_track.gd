extends Toggleable

const DEACTIVATED_FRAME := 7
const LIGHT_FADE_TIME := 1.0
const MAX_LIGHT_POWER := 0.75
const ACTIVATION_TWEEN_TIME := 0.75
const DEACTIVATION_LIGHT_TWEEN_TIME := 0.25
const DEACTIVATION_SOUND_TWEEN_TIME := 1
const ACTIVATE_ANIMATION := "activate"
const DEACTIVATE_ANIMATION := "deactivate"
const INACTIVE_ANIMATION := "inactive"
const BLADE_ACTIVE_ANIMATION := "active"
const POSITION := "position"

@export var delay_time := 0.5
@export var blade_travel_time := 5
@export var off_time := 1
@export var use_ease := true
@export var tween_ease := Tween.EASE_IN_OUT
@export var use_trans := true
@export var tween_trans := Tween.TRANS_EXPO

var _acting := false

@onready var start_point: Node2D = %StartPoint
@onready var end_point: Node2D = %EndPoint
@onready var saw_holder: Node2D = %SawHolder
@onready var saw_blade: AnimatedSprite2D = %SawBlade
@onready var saw_hitbox: Area2D = %SawHitbox
@onready var saw_sound: AudioStreamPlayer2D = %SawSound
@onready var saw_light: PointLight2D = %SawLight
@onready var identifier: AnimatableBody2D = %Identifier
@onready var timer_component: Timer = $TimerComponent
@onready var first_position := start_point.position
@onready var second_position := end_point.position


func _ready() -> void:
	super()
	timer_component.timeout.connect(on_timer_timeout)
	saw_holder.position = start_point.position
	if power_controller.powered:
		do_saw(true)
	else:
		deactivate(true)


func activate(instant: bool = false) -> void:
	var tween_time = g.INSTANT_TIME if instant else ACTIVATION_TWEEN_TIME
	var the_tween = create_tween()
	the_tween.set_parallel()
	the_tween.tween_property(saw_sound, g.DB_PROPERTY, g.SILENT_DB, tween_time)
	the_tween.tween_property(saw_light, g.LIGHT_POWER, MAX_LIGHT_POWER, tween_time)
	saw_sound.play()
	if not instant:
		saw_blade.play(ACTIVATE_ANIMATION)
		await saw_blade.animation_finished
	activated.emit()


func deactivate(instant: bool = false) -> void:
	var tween_time = g.INSTANT_TIME if instant else ACTIVATION_TWEEN_TIME
	saw_blade.play(DEACTIVATE_ANIMATION)
	var the_tween = create_tween()
	the_tween.set_parallel()
	the_tween.tween_property(saw_light, g.LIGHT_POWER, g.NO_LIGHT_POWER, tween_time)
	the_tween.tween_property(saw_sound, g.DB_PROPERTY, g.NORMAL_DB, tween_time).from(g.NORMAL_DB)
	saw_hitbox.monitoring = false
	if not instant:
		await saw_blade.animation_finished
	saw_blade.play(INACTIVE_ANIMATION)
	saw_sound.stop()
	_acting = false
	deactivated.emit()


func do_saw(delayed = false) -> void:
	var position_a = first_position
	var position_b = second_position
	_acting = true
	if delayed:
		await get_tree().create_timer(delay_time, false, true).timeout
	
	if off_time <= 0:
		activate(true)
	else:
		activate()
		await activated

	saw_blade.play(BLADE_ACTIVE_ANIMATION)
	saw_hitbox.monitoring = true
	var the_tween = create_tween()
	(
		the_tween
		. tween_property(saw_holder, POSITION, position_b, blade_travel_time)
		. from(position_a)
		. set_ease(tween_ease if use_ease else Tween.EASE_IN_OUT)
		. set_trans(tween_trans if use_trans else Tween.TRANS_LINEAR)
	)
	await the_tween.finished

	first_position = position_b
	second_position = position_a

	if off_time > 0:
		deactivate()
	else:
		do_saw()


func _physics_process(_delta: float) -> void:
	identifier.global_position = saw_holder.global_position


func make_invisible(instant: bool = false) -> void:
	var tween_time = g.INSTANT_TIME if instant else FADE_TIME
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(saw_light, g.LIGHT_POWER, g.NO_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(saw_sound, g.DB_PROPERTY, g.SILENT_DB, tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, tween_time).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween_time = g.INSTANT_TIME if instant else FADE_TIME
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(saw_light, g.LIGHT_POWER, MAX_LIGHT_POWER,tween_time).from_current()
	tween.tween_property(saw_sound, g.DB_PROPERTY, g.NORMAL_DB, tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, tween_time).from_current()
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
	if powered and not _acting:
		do_saw(true)
	else:
		deactivate()


func on_timer_timeout() -> void:
	if power_controller.powered and not _acting:
		do_saw()
