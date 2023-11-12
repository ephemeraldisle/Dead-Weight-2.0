extends Toggleable


const DEACTIVATED_FRAME = 7
const LIGHT_FADE_TIME = 1.0

@export var delay_time = 0.5
@export var blade_travel_time = 5
@export var off_time = 1
@export var use_ease = true
@export var tween_ease = Tween.EASE_IN_OUT
@export var use_trans = true
@export var tween_trans = Tween.TRANS_EXPO

@onready var start_point: Node2D = %StartPoint
@onready var end_point: Node2D = %EndPoint
@onready var saw_holder: Node2D = %SawHolder
@onready var saw_blade: AnimatedSprite2D = %SawBlade
@onready var saw_hitbox: Area2D = %SawHitbox
@onready var saw_sound: AudioStreamPlayer2D = %SawSound
@onready var saw_light: PointLight2D = %SawLight
@onready var identifier: AnimatableBody2D = %Identifier
@onready var timer_component: Timer = $TimerComponent
@onready var first_position = start_point.position
@onready var second_position = end_point.position

func _ready() -> void:
	super()
	timer_component.timeout.connect(on_timer_timeout)
	saw_holder.position = start_point.position
	if power_controller.powered:
		do_saw()
	else:
		deactivate(true)
	await get_tree().create_timer(delay_time, false, true).timeout


func activate(instant: bool = false) -> void:
	var the_tween = create_tween()
	the_tween.set_parallel()
	the_tween.tween_property(saw_sound, "volume_db", 0, 0.01 if instant else 0.75)
	the_tween.tween_property(saw_light, "energy", 0.75, 0.01 if instant else 0.75)
	saw_sound.play()
	if not instant:
		saw_blade.play("activate")
		await saw_blade.animation_finished
	activated.emit()
	
func deactivate(instant: bool = false) -> void:
	saw_blade.play("deactivate")	
	var the_tween = create_tween()
	the_tween.set_parallel()
	the_tween.tween_property(saw_light, "energy", 0, 0.01 if instant else 0.25)
	the_tween.tween_property(saw_sound, "volume_db", -80, 0.01 if instant else 1.0).from(0)
	saw_hitbox.monitoring = false
	if not instant:
		await saw_blade.animation_finished
	saw_blade.play("inactive")
	saw_sound.stop()
	deactivated.emit()

func do_saw(from_spot: Vector2 = first_position, to_spot: Vector2 = second_position) -> void:
	var position_a = from_spot
	var position_b = to_spot
	
	if off_time <= 0:
		activate(true)
	else:
		activate()
		await activated	
	
	saw_blade.play("active")
	saw_hitbox.monitoring = true
	var the_tween = create_tween()
	the_tween.tween_property(saw_holder, "position", to_spot, blade_travel_time).from(from_spot)\
		.set_ease(tween_ease if use_ease else Tween.EASE_IN_OUT)\
		.set_trans(tween_trans if use_trans else Tween.TRANS_LINEAR)
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
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(saw_light, "energy", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(saw_sound, "volume_db", -80, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_invisible.emit()
	
func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(saw_light, "energy", 1, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(saw_sound, "volume_db", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_visible.emit()

	
func on_power_changed(powered: bool) -> void:
	if powered:
		do_saw()
	else:
		deactivate()

func on_timer_timeout() -> void:
	if power_controller.powered:
		do_saw()
