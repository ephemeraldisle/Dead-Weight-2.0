extends RigidBody2D

@export var raycasts: Array[RayCast2D]
@export var magnet_particles: Array[GPUParticles2D]
@onready var ping_animation = $PingAnimation
@onready var action_finder = $ActionFinder
@onready var shield_animator: AnimationPlayer = %ShieldAnimator
@onready var water_drops: GPUParticles2D = %WaterDrops
@onready var sparks: GPUParticles2D = %Sparks
@onready var magnet_extender: AnimationPlayer = %MagnetExtender
@onready var magnet_loop: AudioStreamPlayer2D = %MagnetLoop
@onready var magnet_open: AudioStreamPlayer2D = %MagnetOpen
@onready var shield_recharge: AudioStreamPlayer2D = %ShieldRecharge
@onready var magnet_close: AudioStreamPlayer2D = %MagnetClose
@onready var shield_ready: AudioStreamPlayer2D = %ShieldReady
@onready var shield_burst: AudioStreamPlayer2D = %ShieldBurst


var grounded = false
var idle = false
var recent_damage = false
var shielded = true
var shield_recharge_time = 6
var shield_down_time = Time.get_unix_time_from_system()
var last_input_time = Time.get_unix_time_from_system()
var magnet_modifier = 1
var magnet_animating = false
var magnet_extended = false

signal tank_hurt

func _ready():
	SharedPlayerManager.tank = self
	

func _physics_process(delta):
	if GameState.dialogue_happening:
		linear_damp=30
		angular_damp=30
	elif !grounded:
		linear_damp=0
		angular_damp=3
	var current_time = Time.get_unix_time_from_system()
#	if current_time - last_input_time > 1:
#		idle = true
#	else:
#		idle = false
#
#	if idle:
#		var rotation_difference = roundi(rotation_degrees) % 360
#		apply_torque_impulse(rotation_difference*-5)
	
	if GameState.shield_enabled && !shielded && SharedPlayerManager.request_energy_percentage() > 0:
		if current_time - shield_down_time > shield_recharge_time:
			shield_recharge.stop()
			shield_ready.play()
			start_shield()
		else:
			if !shield_recharge.playing:
				shield_recharge.play()
			GameEvents.emit_energy_percent_changed(-0.0055)
	else:
		shield_recharge.stop()
		sparks.emitting = false
	
	if !GameState.dialogue_happening && Input.is_action_pressed("move_down") && SharedPlayerManager.request_energy_percentage() > 0:
		do_magnet(delta)
		magnet_modifier += 1
		GameEvents.emit_energy_percent_changed(-0.0055)
		magnet_animation(true)
		for particles in magnet_particles:
			particles.emitting = true
			particles.speed_scale = 1.5
	else:
		grounded = false
		freeze = false
		magnet_animation(false)
		for particles in magnet_particles:
			particles.emitting = false
			particles.speed_scale = 3
		magnet_modifier = 0

#func _input(event):
#	if event.is_action("move_left") or event.is_action("move_right") or event.is_action("move_down"):
#		last_input_time = Time.get_unix_time_from_system()
#

func player_take_damage(impulse: Vector2):
	if recent_damage: return
	tank_hurt.emit()
	GlobalCamera.add_trauma(0.5)
	recent_damage = true
	get_tree().paused = true
	await get_tree().create_timer(0.05).timeout
	get_tree().paused = false
	if shielded:
		remove_shield()
	else:
		apply_central_impulse(impulse*0.5)
		shield_down_time = Time.get_unix_time_from_system()
		water_drops.emitting = true
		GameEvents.emit_water_collected(-randfn(0.1, 0.02))
	await get_tree().create_timer(1, false, true).timeout
	recent_damage = false
	
	
	
	
func remove_shield():
	shield_down_time = Time.get_unix_time_from_system()
	shield_burst.play()
	shield_animator.play("shieldbreak")
	shielded = false
	sparks.emitting = true

func start_shield():
	shielded = true
	sparks.emitting = false
	shield_animator.play_backwards("shieldbreak")
	await shield_animator.animation_finished
	shield_animator.play("on")


func do_magnet(delta: float) -> void:
	var minimum_distance = 1.79769e308
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
		grounded = true
		rotation = angle_to_collision_normal
		freeze = true
	else:
		grounded = false
		freeze = false
		angular_velocity = (angle_to_collision_normal - rotation)
		var direction = global_position.direction_to(collision_point)
		apply_impulse(direction*1000*delta*magnet_modifier)


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
