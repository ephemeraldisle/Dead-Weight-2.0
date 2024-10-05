extends Node2D

signal player_spawned

const PAUSE_FRAME_TIME := 0.05
const MAX_SEPARATION_DISTANCE := 400.0
const DEATH_FADE_TIME := 1.0
const DEATH_PAUSE_TIME := 0.3
const MIDPOINT_FACTOR := 0.5

var player: Node2D
var tank: Node2D
var player_holder := preload("res://Scenes/Objects/Player/player_holder.tscn")
var pickups_in_transit = []
var _dying := false

@onready var hit_sounds: AudioStreamPlayer2D = $HitSounds
#@onready var player_ray: RayCast2D = $PlayerRay
#@onready var tank_ray: RayCast2D = $TankRay
@onready var water_manager: Node = %WaterManager
@onready var energy_manager: Node2D = %EnergyManager
@onready var player_ui: CanvasLayer = $PlayerUI
@onready var thump_sounds: AudioStreamPlayer2D = $ThumpSounds
@onready var activator: Area2D = $Activator

#var _bad_count: int = 0

#func _ready() -> void:
#	await get_tree().create_timer(5).timeout
#	disable_ui()
#	await get_tree().create_timer(2).timeout
#	enable_ui()
#	await get_tree().create_timer(2).timeout
#	disable_ui()

func register_connections() -> void:
#	_bad_count = 0
	var player_connected := false
	var tank_connected := false
	while not player_connected or not tank_connected:
		if player and not player_connected:
#			player.player_damaged.connect(play_hit_sound)
			player_connected = true
		if tank and not tank_connected:
#			tank.tank_hurt.connect(play_hit_sound)
			tank_connected = true
		await get_tree().process_frame
	activator.monitoring = true
	GlobalCamera.follow_node(self)

func _physics_process(_delta: float) -> void:
	if not player or not tank:
		return
	var distance := player.global_position - tank.global_position
	if distance.length() > MAX_SEPARATION_DISTANCE:
		die()
		
	# Place self halfway between the two characters.
	global_position = tank.global_position + distance * MIDPOINT_FACTOR
	
	#Kill player if characters too far apart:
#	tank_ray.global_position = player.global_position
#	player_ray.global_position = tank.global_position
#	player_ray.look_at(player.global_position)
#	tank_ray.look_at(tank.global_position)
#	var player_ray_hit := player_ray.get_collider()
#	var tank_ray_hit := tank_ray.get_collider()
#	if player_ray_hit != player and tank_ray_hit != tank:
#		_bad_count += 1
#	else:
#		_bad_count = 0
#	if _bad_count > 240:
#		print("oh god, dead from rays")
#		die()

func spawn_player() -> void:
	var new_player := player_holder.instantiate()
	get_tree().current_scene.add_child(new_player)
	new_player.global_position = GameState.get_spawn_position()
	player_spawned.emit()
	register_connections()

func despawn_player() -> void:
	activator.monitoring = false
	player.get_parent().queue_free()
	GlobalCamera.follow_position(Vector2.ZERO)

func enable_ui(instant := false) -> void:
	player_ui.toggle_all(true, instant)
	
func disable_ui(instant := false) -> void:
	player_ui.toggle_all(false, instant)

func play_hit_sound() -> void:
	hit_sounds.play()

func clean_up_pickups() -> void:
	for pickup in pickups_in_transit:
		if pickup != null:
			pickup.tween.kill()
			pickup.queue_free()

func play_thump_sound() -> void:
	thump_sounds.play()

func die() -> void:
	if _dying:
		return
	
#	player.play_hurt_sounds()
	_dying = true
	
	activator.monitoring = false
	ScreenTransition.transition(DEATH_FADE_TIME, DEATH_PAUSE_TIME)
	clean_up_pickups()
	await ScreenTransition.after_pause
	player.get_parent().queue_free()
	
	GameState.reset_unsaved_actions()
	spawn_player()
	
	await get_tree().create_timer(DEATH_FADE_TIME, false, true).timeout
	_dying = false

func register_pickup(pickup: Node) -> void:
	pickups_in_transit.append(pickup)

func request_energy_percentage() -> float:
	return energy_manager.current_energy

func request_water_percentage() -> float:
	return water_manager.water_percent

func request_pause_frames() -> void:
	FlowController.pause_game()
	await get_tree().create_timer(PAUSE_FRAME_TIME).timeout
	FlowController.unpause_game()
