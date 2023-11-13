extends Node2D

var player
var tank
#var player_holder = preload("res://Scenes/player_holder.tscn")
var pickups_in_transit = []
var dying = false

@onready var hit_sounds: AudioStreamPlayer2D = $HitSounds
@onready var player_ray: RayCast2D = $PlayerRay
@onready var tank_ray: RayCast2D = $TankRay

var _bad_count: int = 0


func _ready() -> void:
	register_connections()


func register_connections():
	_bad_count = 0
	var player_connected = false
	var tank_connected = false
	while !player_connected or !tank_connected:
		if player and !player_connected:
			player.player_damaged.connect(play_hit_sound)
			player_connected = true
		if tank and !tank_connected:
			tank.tank_hurt.connect(play_hit_sound)
			tank_connected = true
		await get_tree().process_frame
	GlobalCamera.follow_node(self)


func _physics_process(delta):
	if !player or !tank:
		return
	var distance = player.global_position - tank.global_position
	if distance.length() > 400:
		die()
	global_position = tank.global_position + distance * 0.5
	tank_ray.global_position = player.global_position
	player_ray.global_position = tank.global_position
	player_ray.look_at(player.global_position)
	tank_ray.look_at(tank.global_position)
	var player_ray_hit = player_ray.get_collider()
	var tank_ray_hit = tank_ray.get_collider()
	if player_ray_hit != player and tank_ray_hit != tank:
		_bad_count += 1
	else:
		_bad_count = 0
	if _bad_count > 240:
		print("oh god, dead from rays")
		die()


func play_hit_sound():
	hit_sounds.play()


func die():
	if dying:
		return
	player.play_hurt_sounds()
	dying = true
	GlobalCamera.follow_pos(GameState.spawn_point)
	GlobalCamera.snap_to_aim()
	ScreenTransition.transition(1, 0.3)
	for pickup in pickups_in_transit:
		if pickup != null:
			pickup.tween.kill()
			pickup.queue_free()
	await ScreenTransition.after_pause
	if !GameState.crates_cleared && GameState.tutorial_complete:
		get_tree().current_scene.clear_crates()
	player.get_parent().queue_free()
	GameState.reset_unsaved_actions()
#	var new_player = player_holder.instantiate()
#	get_tree().current_scene.add_child(new_player)
#	new_player.global_position = GameState.spawn_point
	register_connections()
	await get_tree().create_timer(1, false, true).timeout
	dying = false


func register_pickup(pickup: Node):
	pickups_in_transit.append(pickup)


func request_energy_percentage() -> float:
	return player.get_battery_percentage()


func request_water_percentage() -> float:
	return player.get_water_percentage()
