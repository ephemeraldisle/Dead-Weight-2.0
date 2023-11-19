extends Node2D

var explosion = preload("res://Scenes/UI/Cinematic/explosions.tscn")
var explosion_sound = preload("res://Scenes/Audio/ship_explosions.tscn")

var x_length
var y_length
var wait_time = 1

func _ready():
	var screen_size = get_viewport_rect().size
	x_length = screen_size.x
	y_length = screen_size.y
	await get_tree().create_timer(2).timeout
	do_spawning()
#resize maybe?

func do_spawning():
	var spawning = true
	while spawning:
		await get_tree().create_timer(randfn(1, 0.5)).timeout
		var random_position = Vector2(randf_range(0, x_length), randf_range(0, y_length))
		var new_explosion = explosion.instantiate() as Node2D
		add_child(new_explosion)
		var random_scale_factor = randfn(1.5, 0.5)
		new_explosion.apply_scale(Vector2(random_scale_factor, random_scale_factor))
		new_explosion.global_position = random_position
		AudioManager.request_audio(explosion_sound, random_position)
		GlobalCamera.add_trauma(randfn(0.2, 0.1))
