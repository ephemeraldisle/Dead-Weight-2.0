extends Toggleable

enum Mode {on, off}

const BARRIER_FADE_TIME = 1.0

@export var starting_mode = Mode.on

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = %Light
@onready var current_mode = starting_mode
@onready var damaging_zone: Area2D = $DamagingZone
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var on_hum: AudioStreamPlayer2D = $"on hum"
@onready var power_down: AudioStreamPlayer2D = $"power down"


func _ready() -> void:
	super()
	if not power_controller.powered or starting_mode == Mode.off:
		deactivate(true)
	else:
		activate(true)


func activate(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 0, 0.01 if instant else BARRIER_FADE_TIME)
	tween.tween_property(on_hum, "volume_db", 0, 0.01 if instant else BARRIER_FADE_TIME).from(-80)
	on_hum.play()
	animated_sprite_2d.play("on")
	damaging_zone.monitoring = true
	light.energy = 1
	current_mode = Mode.on
	activated.emit()

func deactivate(instant: bool = false) -> void:
	damaging_zone.monitoring = false
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 0, 0.01 if instant else BARRIER_FADE_TIME)
	tween.tween_property(on_hum, "volume_db", -80, 0.01 if instant else BARRIER_FADE_TIME)
	if !instant:
		power_down.play()
		animated_sprite_2d.play("deactivate")
		await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("off")
	on_hum.stop()
	current_mode = Mode.off
	deactivated.emit()

func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(light, "energy", 0, 0.01 if instant else FADE_TIME)
	tween.tween_property(on_hum, "volume_db", -80, 0.01 if instant else FADE_TIME)
	await tween.finished
	made_invisible.emit()
	
func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(light, "energy", 1, 0.01 if instant else FADE_TIME)
	tween.tween_property(on_hum, "volume_db", 0, 0.01 if instant else FADE_TIME)
	await tween.finished
	made_visible.emit()
	
func on_power_changed(powered: bool) -> void:
	if powered:
		activate()
	else:
		deactivate()


func toggle_power(reset = false) -> void:
	if current_mode == Mode.on && !reset:
		deactivate()


func _on_damaging_zone_body_entered(body: Node2D) -> void:
	hurt_sound.play()
