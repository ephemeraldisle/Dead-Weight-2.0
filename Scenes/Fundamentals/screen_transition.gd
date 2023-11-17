extends CanvasLayer

const NUMBER_OF_COLORS = 3
const SPREAD_DEGREES = 360 / NUMBER_OF_COLORS
const SPREAD_VARIANCE = 15

signal transitioned_halfway
signal after_pause

@onready var color_rect = $ColorRect


func transition(speed: float = 1, pause_time: float = 0):
	random_directions()
	$AnimationPlayer.speed_scale = speed
	$AnimationPlayer.play("default")
	$AudioStreamPlayer.play()
	await $AnimationPlayer.animation_finished
	transitioned_halfway.emit()
	await get_tree().create_timer(pause_time).timeout
	after_pause.emit()
	random_directions()
	$AnimationPlayer.play_backwards("default")


func random_directions():
	var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	color_rect.material.set_shader_parameter("direction_r", direction)
	direction = direction.rotated(deg_to_rad(randfn(SPREAD_DEGREES, SPREAD_VARIANCE)))
	color_rect.material.set_shader_parameter("direction_g", direction)
	direction = direction.rotated(deg_to_rad(randfn(SPREAD_DEGREES, SPREAD_VARIANCE)))
	color_rect.material.set_shader_parameter("direction_b", direction)
