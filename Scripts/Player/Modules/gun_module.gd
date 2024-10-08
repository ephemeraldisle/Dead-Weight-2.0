extends Node2D

const ENERGY_COST := 0.25
const KICKBACK_POWER := 5000
const BULLET_POWER := 500
const NO_ENERGY := 0.0
const FIRE_ANIMATION = "Fire"
const FIRE_ACTION = "click"
const RESET_ANIMATION = "RESET"

@export var bullet: PackedScene
@export var fire_point: Node2D
@export var gun_animator: AnimationPlayer

var target
var gpu_particles_2d = preload("res://Scenes/Particles/bullet sparks.tscn")

@onready var parent = get_parent()
@onready var foreground = get_tree().get_first_node_in_group("foreground")
@onready var ability_power_controller: Node = $AbilityPowerController
@onready var fire_audio: AudioStreamPlayer2D = $PlayerLasers

func _physics_process(_delta):
	look_at(get_global_mouse_position())

func _input(event):
	if not ability_power_controller.powered:
		return
		
	if event.is_action_pressed(FIRE_ACTION) and SharedPlayerManager.request_energy_percentage() > NO_ENERGY:
		if gun_animator.is_playing():
			gun_animator.play(RESET_ANIMATION)	
		gun_animator.play(FIRE_ANIMATION)
		
		target = get_global_mouse_position()
		var direction = (fire_point.global_position-target).normalized()
		parent.apply_central_impulse(direction * KICKBACK_POWER)
		
		var new_bullet = bullet.instantiate() as RigidBody2D
		foreground.add_child(new_bullet)
		
		var particles = gpu_particles_2d.instantiate() as GPUParticles2D
		foreground.add_child(particles)
		particles.global_position = fire_point.global_position
		particles.emitting = true
		
		new_bullet.global_position = fire_point.global_position
		new_bullet.apply_central_impulse(-direction * BULLET_POWER)
		
		fire_audio.play()
		GameEvents.emit_energy_percent_changed(-ENERGY_COST)
