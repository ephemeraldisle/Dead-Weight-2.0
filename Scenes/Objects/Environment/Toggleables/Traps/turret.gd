extends Toggleable

signal finished_charging

const ANIMATION_TIME = 0.6875
const LASER_ADJUST_SCALE = Vector2(2.124, 2.124)

@export var laser: PackedScene
@export var light: PackedScene
@export var initial_delay := 0.5
@export var off_time := 3.0
@export var speed_factor = 100
@export var debug = false

var _firing = false

@onready var fire_point: Sprite2D = $FirePoint
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var charge_sound: AudioStreamPlayer2D = %ChargeSound
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var foreground = get_tree().get_first_node_in_group("foreground")
@onready var timer_component: Timer = $TimerComponent


func _ready() -> void:
	off_time = max(off_time - ANIMATION_TIME, 0.01)
	timer_component.change_time(off_time)
	timer_component.timeout.connect(on_timer_timeout)
	super()

	if not power_controller.powered:
		deactivate(true)
	else:
		fire_laser()


func fire_laser() -> void:
	if _firing:
		return
	_firing = true
	await get_tree().create_timer(initial_delay).timeout
	charge_up()
	await finished_charging
	activate()
	_firing = false
	deactivate()


func charge_up():
	animated_sprite_2d.play("fire")
	charge_sound.play()
	if debug:
		print_debug("%s chargin up" % self)
	await get_tree().create_timer(ANIMATION_TIME, false, true).timeout
	finished_charging.emit()


func activate(_instant: bool = false) -> void:
	if !power_controller.powered:
		return

	fire_sound.play()
	var new_laser = laser.instantiate()

	new_laser.scale = LASER_ADJUST_SCALE
	foreground.add_child(new_laser)
	new_laser.global_position = fire_point.global_position
	var direction = global_position.direction_to(fire_point.global_position)
	var laser_velocity = direction * speed_factor
	new_laser.rotation = direction.angle()

	var lite = light.instantiate()
	new_laser.add_child(lite)
	new_laser.program_projectile(laser_velocity, lite)

	activated.emit()


func deactivate(_instant: bool = false) -> void:
	deactivated.emit()


func on_timer_timeout() -> void:
	if power_controller.powered:
		fire_laser()


func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
	if powered:
		fire_laser()
	else:
		deactivate()
