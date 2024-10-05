extends Node2D

const EXPLOSION_SCENE := preload("res://Scenes/UI/Cinematic/explosions.tscn")
const EXPLOSION_SOUND := preload("res://Scenes/Audio/ship_explosions.tscn")

const INITIAL_DELAY := 2.0
const SPAWN_INTERVAL_MEAN := 1.0
const SPAWN_INTERVAL_DEVIATION := 0.5
const SCALE_MEAN := 1.5
const SCALE_DEVIATION := 0.5
const TRAUMA_MEAN := 0.2
const TRAUMA_DEVIATION := 0.1

var _viewport_size: Vector2

func _ready() -> void:
	_viewport_size = get_viewport_rect().size
	await get_tree().create_timer(INITIAL_DELAY).timeout
	do_spawning()

func do_spawning() -> void:
	while true:
		await get_tree().create_timer(randfn(SPAWN_INTERVAL_MEAN, SPAWN_INTERVAL_DEVIATION)).timeout
		spawn_explosion()

func spawn_explosion() -> void:
	var random_position := Vector2(randf_range(0, _viewport_size.x), randf_range(0, _viewport_size.y))
	var new_explosion := EXPLOSION_SCENE.instantiate() as Node2D
	add_child(new_explosion)
	
	var random_scale_factor := randfn(SCALE_MEAN, SCALE_DEVIATION)
	new_explosion.scale = Vector2(random_scale_factor, random_scale_factor)
	new_explosion.global_position = random_position
	
	AudioManager.request_audio(EXPLOSION_SOUND, random_position)
	GlobalCamera.add_trauma(randfn(TRAUMA_MEAN, TRAUMA_DEVIATION))