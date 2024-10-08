extends Toggleable

enum Mode { on, off }

const BARRIER_FADE_TIME := 1.0
const ACTIVATE_ANIMATION := "on"
const DEACTIVATE_ANIMATION := "deactivate"
const OFF_ANIMATION := "off"

@export var starting_mode := Mode.on

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var light: PointLight2D = %Light
@onready var current_mode: Mode = starting_mode
@onready var damaging_zone: Area2D = $DamagingZone
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var on_hum: AudioStreamPlayer2D = $"on hum"
@onready var power_down: AudioStreamPlayer2D = $"power down"
@onready var wall: StaticBody2D = %Wall


func _ready() -> void:
	super()
	if not power_controller.powered or starting_mode == Mode.off:
		deactivate(true)
	else:
		activate(true)


func activate(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.FULL_LIGHT_POWER, g.INSTANT_TIME if instant else BARRIER_FADE_TIME)
	tween.tween_property(on_hum, g.DB_PROPERTY, g.NORMAL_DB, g.INSTANT_TIME if instant else BARRIER_FADE_TIME).from(g.SILENT_DB)
	on_hum.play()
	animated_sprite_2d.play(ACTIVATE_ANIMATION)
	damaging_zone.monitoring = true
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, true)
	current_mode = Mode.on
	activated.emit()


func deactivate(instant: bool = false) -> void:
	damaging_zone.monitoring = false
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER, g.INSTANT_TIME if instant else BARRIER_FADE_TIME)
	tween.tween_property(on_hum, g.DB_PROPERTY, g.SILENT_DB, g.INSTANT_TIME if instant else BARRIER_FADE_TIME)
	if !instant:
		power_down.play()
		animated_sprite_2d.play(DEACTIVATE_ANIMATION)
		await animated_sprite_2d.animation_finished
	animated_sprite_2d.play(OFF_ANIMATION)
	on_hum.stop()
	current_mode = Mode.off
	deactivated.emit()


func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, g.INSTANT_TIME if instant else FADE_TIME).from_current()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER, g.INSTANT_TIME if instant else FADE_TIME)
	tween.tween_property(on_hum, g.DB_PROPERTY, g.SILENT_DB, g.INSTANT_TIME if instant else FADE_TIME)
	await tween.finished
	made_invisible.emit()


func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, g.INSTANT_TIME if instant else FADE_TIME).from_current()
	tween.tween_property(light, g.LIGHT_POWER, g.FULL_LIGHT_POWER, g.INSTANT_TIME if instant else FADE_TIME)
	tween.tween_property(on_hum, g.DB_PROPERTY, g.NORMAL_DB, g.INSTANT_TIME if instant else FADE_TIME)
	await tween.finished
	made_visible.emit()


func on_power_changed(powered: bool) -> void:
	if powered:
		activate()
	else:
		deactivate()


func toggle_power(reset = false) -> void:
	if current_mode == Mode.on and !reset:
		deactivate()


func _on_damaging_zone_body_entered(_body: Node2D) -> void:
	hurt_sound.play()
