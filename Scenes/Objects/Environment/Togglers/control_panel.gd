extends StaticBody2D

const DISABLED_COLOR = Color("00fefeff")
const ENABLED_COLOR = Color("fe0000ff")
const FADE_TIME = 0.25

@export var linked_objects_start_active: Array[Node2D]
@export var linked_objects_start_deactive: Array[Node2D]
@export var sound_to_play: AudioStream
@export var reset_time = -1.0
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var light: PointLight2D = $PointLight2D
@onready var toggler_component: Node2D = $TogglerComponent as Toggler

var available_to_act = true

signal action_finished
signal action_reset


func _ready():
	toggler_component.register_active_objects(linked_objects_start_active)
	toggler_component.register_inactive_objects(linked_objects_start_deactive)
	toggler_component.toggled_from_save.connect(check_save_data.bind(true))
	audio_player.set_stream(sound_to_play)
	check_save_data(true)


func check_save_data(instant: bool = false) -> void:
	if toggler_component.toggled:
		set_enabled()
	else:
		set_disabled(instant)


func set_enabled() -> void:
	light.color = ENABLED_COLOR
	animated_sprite_2d.play("Active")
	action_reset.emit()
	available_to_act = true


func set_disabled(instant: bool = false) -> void:
	light.color = DISABLED_COLOR
	action_finished.emit()
	if !instant:
		animated_sprite_2d.play("DeactivateStart")
		await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("DeactivateLoop")


func make_invisible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 0, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 0, 0.01 if instant else FADE_TIME).from_current()


func make_visible(instant: bool = false) -> void:
	var tween = create_tween()
	tween.set_parallel()
	tween.tween_property(light, "energy", 1, 0.01 if instant else FADE_TIME).from_current()
	tween.tween_property(self, "modulate:a", 1, 0.01 if instant else FADE_TIME).from_current()


func do_action(need_sound: bool = true):
	if !available_to_act:
		action_finished.emit()
		return
	if need_sound:
		audio_player.play()
	# we don't know why we wait here
#	await get_tree().create_timer(0.25, false, true).timeout
	toggler_component.set_off()
	set_disabled()
	available_to_act = false
	if reset_time >= 0:
		await get_tree().create_timer(reset_time).timeout
		toggler_component.set_on()
		set_enabled()
