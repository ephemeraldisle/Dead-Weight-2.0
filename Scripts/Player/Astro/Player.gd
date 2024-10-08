class_name Player
extends RigidBody2D

signal player_jetpacked
signal player_damaged

const RECENT_CONTACT_TIME := 0.5
const DAMAGE_VELOCITY := 300
const MIN_DAMAGE_ANGLE := 60
const MAX_DAMAGE_ANGLE := 120
const STANDARD_SCREENSHAKE_NUMBER := 0.5
const DAMAGE_COOLDOWN := 1.0
const FULL_ROTATION := 2 * PI

@export var tank: PhysicsBody2D
@export var rope_holder: RopeHolder
@export var hurt_sounds: AudioStream

@onready var pointer := $Pointer
@onready var health_manager := %HealthManager
@onready var ping_animation := $PingAnimation
@onready var _head_area := $HeadArea
@onready var attachment_point := %AttachmentPoint
@onready var _gun_arm := $GunArm
@onready var _gun_art : Sprite2D = _gun_arm.gun

var _head_collision_particles := preload("res://Scenes/Particles/power_node_hit_particles.tscn")
var _recent_damage := false 


func _ready() -> void:
	#GlobalCamera.follow_node(self)
	if not GameState.state.abilities.gun:
		GameEvents.gun_collected.connect(_enable_gun)
	else:
		_enable_gun()
	SharedPlayerManager.player = self
#	if GameState.tutorial_complete || GameState.death_enabled:
#		enable_all_ui()


func _physics_process(_delta: float) -> void:
	pointer.position = get_local_mouse_position()


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.get_contact_count() <= 0: return
	
	for contact_index in range(state.get_contact_count()):
		var collider := state.get_contact_collider_object(contact_index)
		if not collider is TileMap:
			continue
		var collision_normal := state.get_contact_local_normal(contact_index)
		var collision_velocity := state.get_contact_local_velocity_at_position(contact_index).length()
		var collision_angle := atan2(collision_normal.y, collision_normal.x)
		var relative_angle := _normalize_angle(collision_angle - rotation)

		if _is_head_collision(relative_angle) and _is_damaging_velocity(collision_velocity):
			_spawn_head_collision_particles()
			player_take_damage(Vector2.ZERO)
			break


func _is_head_collision(angle: float) -> bool:
	return angle >= deg_to_rad(MIN_DAMAGE_ANGLE) and angle <= deg_to_rad(MAX_DAMAGE_ANGLE)


func _is_damaging_velocity(velocity: float) -> bool:
	return velocity > DAMAGE_VELOCITY


func _spawn_head_collision_particles() -> void:
	var particles := _head_collision_particles.instantiate() as GPUParticles2D
	add_child(particles)
	particles.global_position = _head_area.global_position
	particles.emitting = true


func _enable_gun() -> void:
	_gun_art.visible = true
	_gun_arm.target = null


func _normalize_angle(angle: float) -> float:
	return fmod(angle + FULL_ROTATION, FULL_ROTATION)


	
func player_take_damage(impulse: Vector2) -> void:
	if _recent_damage: return
	player_damaged.emit()
	GlobalCamera.add_trauma(STANDARD_SCREENSHAKE_NUMBER)
	_recent_damage = true
	linear_velocity = Vector2.ZERO
	SharedPlayerManager.request_pause_frames()
	apply_central_impulse(impulse)
	await get_tree().create_timer(DAMAGE_COOLDOWN, false, true).timeout
	_recent_damage = false

#func play_hurt_sounds() -> void:
#	AudioManager.play_generic(hurt_sounds, global_position)

#func enable_battery_ui() -> void:
#	player_ui.enable_battery_ui()
#
#func enable_water_ui() -> void:
#	player_ui.enable_water_ui()
#func enable_health_ui() -> void:
#	player_ui.enable_health_ui()
#func enable_water_drain() -> void:
#	water_manager.waterActive = true
#
#func enable_all_ui() -> void:
#	enable_water_ui()
#	enable_health_ui()
#	enable_battery_ui()
#	enable_water_drain()
