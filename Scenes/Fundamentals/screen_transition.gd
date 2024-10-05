extends CanvasLayer

signal transitioned_halfway
signal after_pause

const NUMBER_OF_COLORS := 3.0
const SPREAD_DEGREES := 360 / NUMBER_OF_COLORS
const SPREAD_VARIANCE = 15
const MIN_ROTATION = 0

const DEFAULT_SPEED = 1
const DEFAULT_PAUSE_LENGTH = 0

const DEFAULT_ANIM := "default"
const R_PARAM := "direction_r"
const G_PARAM := "direction_g"
const B_PARAM := "direction_b"



@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func transition(speed: float = DEFAULT_SPEED, pause_time: float = DEFAULT_PAUSE_LENGTH):
	_assign_random_aberration_directions()

	animation_player.speed_scale = speed
	animation_player.play(DEFAULT_ANIM)
	audio_stream_player.play()
	await animation_player.animation_finished
	transitioned_halfway.emit()
	await get_tree().create_timer(pause_time).timeout
	after_pause.emit()
	_assign_random_aberration_directions()
	animation_player.play_backwards(DEFAULT_ANIM)


func _assign_random_aberration_directions():
	var direction = Vector2.RIGHT.rotated(randf_range(MIN_ROTATION, TAU))
	color_rect.material.set_shader_parameter(R_PARAM, direction)
	direction = direction.rotated(deg_to_rad(randfn(SPREAD_DEGREES, SPREAD_VARIANCE)))
	color_rect.material.set_shader_parameter(G_PARAM, direction)
	direction = direction.rotated(deg_to_rad(randfn(SPREAD_DEGREES, SPREAD_VARIANCE)))
	color_rect.material.set_shader_parameter(B_PARAM, direction)
