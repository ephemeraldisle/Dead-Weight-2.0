extends Toggleable

const ANIMATION_TIME = 0.4

@export var start_closed = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var pressure_activator: Area2D = $PressureActivator

@onready var ajar = not start_closed

func _ready() -> void:
	super()
	pressure_activator.pressure_activated.connect(on_pressure_activated)
	if not power_controller.powered or not start_closed:
		deactivate(true)

func activate(instant: bool = false) -> void:
	animation_player.speed_scale = 99 if instant else 1
	animation_player.play_backwards("open")
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
	ajar = true
	deactivated.emit()

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
		activate()
	else:
		deactivate()

func on_pressure_activated() -> void:
	if power_controller.powered:
		if ajar:
			activate()
		else:
			deactivate()
