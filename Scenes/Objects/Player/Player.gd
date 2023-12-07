extends RigidBody2D

@export var tank: PhysicsBody2D
@export var rope_holder: RopeHolder
@onready var pointer = $Pointer
@onready var health_manager = %HealthManager
@onready var ping_animation = $PingAnimation
@onready var jetpack = $Jetpack
@onready var action_finder = $ActionFinder
@onready var head_area: Area2D = $HeadArea
@onready var attachment_point = %AttachmentPoint
@export var hurt_sounds: AudioStream
@onready var gun: Sprite2D = %Gun


var lil_party = preload("res://Scenes/Particles/power_node_hit_particles.tscn")
var skeleton_mods = preload("res://Resources/skeleton modifications.tres")


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
	if !GameState.state.abilities.gun:
		GameEvents.gun_collected.connect(getgun)
	else:
		getgun()
	SharedPlayerManager.player = self
#	if GameState.tutorial_complete || GameState.death_enabled:
#		enable_all_ui()
#	jetpack.jetpacked.connect(jetpacked)
	await get_tree().create_timer(0.2, false, true).timeout
#	skeleton_2d.set_modification_stack(skeleton_mods)
	
func _physics_process(_delta):
	pointer.position = get_local_mouse_position()


	
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

#func play_hurt_sounds():
#	AudioManager.play_generic(hurt_sounds, global_position)

#func enable_battery_ui():
#	player_ui.enable_battery_ui()
#
#func enable_water_ui():
#	player_ui.enable_water_ui()
#func enable_health_ui():
#	player_ui.enable_health_ui()
#func jetpacked():
#	player_jetpacked.emit()
#func enable_water_drain():
#	water_manager.waterActive = true
#
#func enable_all_ui():
#	enable_water_ui()
#	enable_health_ui()
#	enable_battery_ui()
#	enable_water_drain()
