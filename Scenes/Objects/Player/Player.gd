extends RigidBody2D

@export var tank: PhysicsBody2D
@export var rope_holder: RopeHolder
@onready var pointer = $Pointer
@onready var health_manager = %HealthManager
@onready var battery_manager = %BatteryManager
@onready var ping_animation = $PingAnimation
@onready var player_ui = $PlayerUI
@onready var jetpack = $Jetpack
@onready var water_manager = %WaterManager
@onready var action_finder = $ActionFinder
@onready var skeleton_2d = $Skeleton2D
@onready var gun = $Skeleton2D/Spine/FrontUpperArmBone/FrontLowerArmBone/Bone2D/Gun
@onready var head_area: Area2D = $HeadArea

@onready var attachment_point = %AttachmentPoint
@export var hurt_sounds: AudioStream


var lil_party = preload("res://Scenes/Projectiles/power_node_hit_particles.tscn")
var skeleton_mods = preload("res://Scenes/Objects/skeleton modifications.tres")

signal player_rotated
signal player_jetpacked
var left_rotation = false
var right_rotation = false
var monitoring_rotation = false

signal player_damaged
var recent_damage = false
var left_multiplier = 1
var right_multiplier = 1
@onready var original_angular_damping = angular_damp

func getgun():
	gun.visible = true
	
func _ready():
	#GlobalCamera.follow_node(self)
#	rope_holder.global_position = attachment_point.global_position
#	tank.global_position = attachment_point.global_position + Vector2(0,98)
	if !GameState.gun_enabled:
		GameEvents.gun_collected.connect(getgun)
	else:
		getgun()
	SharedPlayerManager.player = self
	if GameState.tutorial_complete || GameState.death_enabled:
		enable_all_ui()
	rope_holder.set_origin_attach(self.get_path())
	rope_holder.set_end_attach(tank.get_path())
	jetpack.jetpacked.connect(jetpacked)
	await get_tree().create_timer(0.2, false, true).timeout
	skeleton_2d.set_modification_stack(skeleton_mods)
	
func _physics_process(delta):
	if GameState.introduction_running &&!GameState.rotation_enabled:	
		return	
	pointer.position = get_local_mouse_position()
	if GameState.dialogue_happening:
		linear_damp=30
		angular_damp=30
		return
	else:
		linear_damp=0
		angular_damp=original_angular_damping
	var rotating = false
	if Input.is_action_pressed("move_left"):
		if monitoring_rotation:
			left_rotation = true
		angular_damp = 0
		rotating = true
		if battery_manager.current_percent > 0:
			apply_torque_impulse(-500*left_multiplier)
			left_multiplier = min(left_multiplier+1, 10)
			battery_manager.change_energy(-min(left_multiplier*0.0015, 0.01))
		else:
			apply_torque_impulse(-250)
	else:
		left_multiplier = 1
	if Input.is_action_pressed("move_right"):
		if monitoring_rotation:
			right_rotation = true
		angular_damp = 0
		rotating = true
		if battery_manager.current_percent > 0:
			apply_torque_impulse(500*right_multiplier)
			right_multiplier = min(right_multiplier+1, 10)
			battery_manager.change_energy(-min(right_multiplier*0.0015, 0.01))
		else: 
			apply_torque_impulse(250)
	else:
		right_multiplier = 1
		
	if !rotating:
		angular_damp = original_angular_damping
	
	if monitoring_rotation and left_rotation and right_rotation:
		#print("we did it! we rotated!")
		player_rotated.emit()
		monitoring_rotation = false
	
	
func _on_body_entered(other: Node2D):
	if not other is TileMap:
		if other.get_collision_layer_value(6) or other.get_collision_layer_value(4) or other.get_collision_layer_value(6):
			return
	if head_area.get_overlapping_bodies().size() > 0 && linear_velocity.length() > 300 && !recent_damage:
		var party = lil_party.instantiate() as GPUParticles2D
		add_child(party)
		party.global_position = head_area.global_position
		party.emitting = true
		player_take_damage(Vector2.ZERO)

func player_take_damage(impulse: Vector2):
	if recent_damage: return
	player_damaged.emit()
	GlobalCamera.add_trauma(0.5)
	recent_damage = true
	get_tree().paused = true
	await get_tree().create_timer(0.05).timeout
	get_tree().paused = false
	apply_central_impulse(impulse)
	await get_tree().create_timer(1, false, true).timeout
	recent_damage = false

func play_hurt_sounds():
	AudioManager.play_generic(hurt_sounds, global_position)

func enable_battery_ui():
	player_ui.enable_battery_ui()
	
func enable_water_ui():
	player_ui.enable_water_ui()
func enable_health_ui():
	player_ui.enable_health_ui()
func jetpacked():
	player_jetpacked.emit()
func enable_water_drain():
	water_manager.waterActive = true

func enable_all_ui():
	enable_water_ui()
	enable_health_ui()
	enable_battery_ui()
	enable_water_drain()

func get_battery_percentage() -> float:
	return battery_manager.current_percent

func get_water_percentage() -> float:
	return water_manager.water_percent

func _input(event):
	if GameState.dialogue_happening:
		return
	if GameState.death_enabled:
		if event.is_action_pressed("restart"):
			SharedPlayerManager.die()
	if event.is_action_pressed("interact"):
		if !action_finder.attempt_to_act():
			SharedPlayerManager.tank.action_finder.attempt_to_act()
