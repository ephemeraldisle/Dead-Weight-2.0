extends Toggleable

const ANIMATION_TIME = 0.4

@export var start_closed = true
@export var use_pressure = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pressure_activator: Area2D = $PressureActivator
@onready var light: PointLight2D = $PointLight2D
@onready var light_occluder_2d: LightOccluder2D = $LightOccluder2D as LightOccluder2D

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
	animation_player.speed_scale = 99 if instant else 1
	animation_player.play_backwards("open")	
	light_occluder_2d.visible = true
	light.visible = true
	if !instant:
		await get_tree().create_timer(ANIMATION_TIME).timeout
	collision_shape_2d.set_deferred("disabled", false)
	ajar = false
	activated.emit()


func deactivate(instant: bool = false) -> void:
	animation_player.speed_scale = 99 if instant else 1
	animation_player.play("open")
	if !instant:
		await get_tree().create_timer(ANIMATION_TIME).timeout
	collision_shape_2d.set_deferred("disabled", true)
	light_occluder_2d.visible = false
	light.visible = false
	ajar = true
	deactivated.emit()


func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 1, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()
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
