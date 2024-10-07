class_name MagnetModule
extends Node2D

const MAGNET_DAMPING := 500.0
const MAGNET_MASS := 500.0
const ENERGY_COST := 0.0055
const MAGNET_RANGE := 250.0
const MAGNET_FORCE := 1000.0
const HALF_PI := PI / 2.0
const PARTICLE_ACTIVE_SPEED := 1.5
const PARTICLE_INACTIVE_SPEED := 3.0
const MODIFIER_PER_FRAME := 1
const NO_ENERGY := 0
const EXTEND_ANIMATION := "extend"

@export var raycasts: Array[RayCast2D]
@export var magnet_particles: Array[GPUParticles2D]

var magnet_modifier := 0
var magnet_animating := false
var magnet_extended := false

@onready var magnet_extender: AnimationPlayer = %MagnetExtender
@onready var magnet_loop: AudioStreamPlayer2D = %MagnetLoop
@onready var magnet_open: AudioStreamPlayer2D = %MagnetOpen
@onready var magnet_close: AudioStreamPlayer2D = %MagnetClose
@onready var ability_power_controller: AbilityPowerController = $AbilityPowerController
@onready var parent: RigidBody2D = get_parent()
@onready var original_linear_damp := parent.linear_damp
@onready var original_mass := parent.mass

func _physics_process(delta: float) -> void:
	if not ability_power_controller.powered:
		return
		
	if Input.is_action_pressed(g.MAGNET_BUTTON) and SharedPlayerManager.request_energy_percentage() > NO_ENERGY:
		do_magnet(delta)
		magnet_modifier += MODIFIER_PER_FRAME
		GameEvents.emit_energy_percent_changed(-ENERGY_COST)
		magnet_animation(true)
		set_particle_state(true)
	else:
		reset_parent_properties()
		magnet_animation(false)
		set_particle_state(false)
		magnet_modifier = 0

func do_magnet(delta: float) -> void:
	var chosen_ray := get_closest_ray()
	if chosen_ray == null:
		return

	var collision_point := chosen_ray.get_collision_point()
	var collision_normal := chosen_ray.get_collision_normal()
	var angle_to_collision_normal := atan2(collision_normal.y, collision_normal.x) + HALF_PI
	var distance := global_position.distance_squared_to(collision_point)

	if distance <= MAGNET_RANGE:
		apply_close_range_magnet(angle_to_collision_normal)
	else:
		apply_long_range_magnet(angle_to_collision_normal, collision_point, delta)

func get_closest_ray() -> RayCast2D:
	var minimum_distance := INF
	var chosen_ray: RayCast2D = null
	for ray in raycasts:
		if ray.is_colliding():
			var distance := global_position.distance_squared_to(ray.get_collision_point())
			if distance < minimum_distance:
				minimum_distance = distance
				chosen_ray = ray
	return chosen_ray

func apply_close_range_magnet(angle: float) -> void:
	parent.linear_damp = MAGNET_DAMPING
	parent.mass = MAGNET_MASS
	parent.rotation = angle

func apply_long_range_magnet(angle: float, collision_point: Vector2, delta: float) -> void:
	reset_parent_properties()
	parent.angular_velocity = angle - rotation
	var direction := global_position.direction_to(collision_point)
	parent.apply_impulse(direction * MAGNET_FORCE * delta * magnet_modifier)

func reset_parent_properties() -> void:
	parent.linear_damp = original_linear_damp
	parent.mass = original_mass

func set_particle_state(active: bool) -> void:
	for particles in magnet_particles:
		particles.emitting = active
		particles.speed_scale = PARTICLE_ACTIVE_SPEED if active else PARTICLE_INACTIVE_SPEED

func magnet_animation(extending: bool) -> void:
	if extending and not magnet_extended:
		extend_magnet()
	elif not extending and magnet_extended:
		retract_magnet()

func extend_magnet() -> void:
	magnet_animating = true
	magnet_extender.play(EXTEND_ANIMATION)
	magnet_open.play()
	await magnet_extender.animation_finished
	magnet_loop.play()
	magnet_extended = true

func retract_magnet() -> void:
	magnet_animating = true
	magnet_extender.play_backwards(EXTEND_ANIMATION)
	magnet_loop.stop()
	magnet_close.play()
	await magnet_extender.animation_finished
	magnet_extender.play(g.RESET_ANIMATION)
	magnet_extended = false