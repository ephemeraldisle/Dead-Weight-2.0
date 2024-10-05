extends Toggleable

const ANIMATION_TIME = 0.4
const INSTANT_SPEED = 99
const NORMAL_SPEED = 1
const ANIMATION_NAME = "open"
const COLLISION_DISABLED = "disabled"

@export var start_closed = true
@export var use_pressure = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pressure_activator: Area2D = $PressureActivator
@onready var light: PointLight2D = $PointLight2D
@onready var light_occluder_2d: LightOccluder2D = $LightOccluder2D

@onready var ajar = not start_closed

func _ready() -> void:
	super()
	if use_pressure:
		pressure_activator.pressure_activated.connect(on_pressure_activated)
	else:
		pressure_activator.queue_free()
	if not power_controller.powered or not start_closed:
		deactivate(true)


func activate(instant: bool = false) -> void:
	animation_player.speed_scale = INSTANT_SPEED if instant else NORMAL_SPEED
	animation_player.play_backwards(ANIMATION_NAME)	
	light_occluder_2d.visible = true
	light.visible = true
	if !instant:
		await get_tree().create_timer(ANIMATION_TIME).timeout
	collision_shape_2d.set_deferred(COLLISION_DISABLED, false)
	ajar = false
	activated.emit()


func deactivate(instant: bool = false) -> void:
	animation_player.speed_scale = INSTANT_SPEED if instant else NORMAL_SPEED
	animation_player.play(ANIMATION_NAME)
	if !instant:
		await get_tree().create_timer(ANIMATION_TIME).timeout
	collision_shape_2d.set_deferred(COLLISION_DISABLED, true)
	light_occluder_2d.visible = false
	light.visible = false
	ajar = true
	deactivated.emit()


func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER, g.INSTANT_TIME if instant else FADE_TIME).from_current()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, g.INSTANT_TIME if instant else FADE_TIME).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.FULL_LIGHT_POWER, g.INSTANT_TIME if instant else FADE_TIME).from_current()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, g.INSTANT_TIME if instant else FADE_TIME).from_current()
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
	if powered:
		activate()
	else:
		deactivate()


func on_pressure_activated() -> void:
	if power_controller.powered:
		if ajar:
			activate()
		else:
			deactivate()
