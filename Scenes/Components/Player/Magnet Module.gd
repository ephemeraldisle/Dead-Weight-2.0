class_name MagnetModule
extends Node2D

const MAGNET_DAMPING = 500
const MAGNET_MASS = 500

@export var raycasts: Array[RayCast2D]
@export var magnet_particles: Array[GPUParticles2D]

var magnet_modifier = 0
var magnet_animating = false
var magnet_extended = false

@onready var magnet_extender: AnimationPlayer = %MagnetExtender
@onready var magnet_loop: AudioStreamPlayer2D = %MagnetLoop
@onready var magnet_open: AudioStreamPlayer2D = %MagnetOpen
@onready var magnet_close: AudioStreamPlayer2D = %MagnetClose
@onready var ability_power_controller: Node = $AbilityPowerController as AbilityPowerController
@onready var parent = get_parent() as RigidBody2D
@onready var original_linear_damp = parent.linear_damp
@onready var original_mass = parent.mass

func _physics_process(delta):
	if not ability_power_controller.powered:
		return
		
	if Input.is_action_pressed("down") && SharedPlayerManager.request_energy_percentage() > 0:
		do_magnet(delta)
		magnet_modifier += 1
		GameEvents.emit_energy_percent_changed(-0.0055)
		magnet_animation(true)
		for particles in magnet_particles:
			particles.emitting = true
			particles.speed_scale = 1.5
	else:
		parent.linear_damp = original_linear_damp
		parent.mass = original_mass
		magnet_animation(false)
		for particles in magnet_particles:
			particles.emitting = false
			particles.speed_scale = 3
		magnet_modifier = 0

func do_magnet(delta: float) -> void:
	var minimum_distance = INF
	var chosen_ray
	for ray in raycasts:
		if ray.is_colliding():
			var distance = global_position.distance_squared_to(ray.get_collision_point())
			if distance < minimum_distance:
				minimum_distance = distance
				chosen_ray = ray
	if chosen_ray == null:
#		print("I choose nothing")
		return
#	print(minimum_distance)
	var collision_point = chosen_ray.get_collision_point()
	var collision_normal = chosen_ray.get_collision_normal()
	var angle_to_collision_normal = atan2(collision_normal.y, collision_normal.x)+PI/2
	if minimum_distance <= 250:
		parent.linear_damp = MAGNET_DAMPING
		parent.mass = MAGNET_MASS
		parent.rotation = angle_to_collision_normal
	else:
		parent.linear_damp = original_linear_damp
		parent.mass = original_mass
		parent.angular_velocity = (angle_to_collision_normal - rotation)
		var direction = global_position.direction_to(collision_point)
		parent.apply_impulse(direction*1000*delta*magnet_modifier)


func magnet_animation(extending: bool) -> void:
	if extending && !magnet_extended:
		magnet_animating = true
		magnet_extender.play("extend")
		magnet_open.play()
		await magnet_extender.animation_finished
		magnet_loop.play()
		magnet_extended=true
	elif !extending && magnet_extended:
		magnet_animating = true
		magnet_extender.play_backwards("extend")
		magnet_loop.stop()
		magnet_close.play()
		await magnet_extender.animation_finished
		magnet_extender.play("RESET")
		magnet_extended=false
