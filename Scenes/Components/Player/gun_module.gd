extends Node2D

const ENERGY_COST = 0.25
const KICKBACK_POWER = 5000
const BULLET_POWER = 500

@export var bullet: PackedScene
var target

@onready var parent = get_parent()
@onready var foreground = get_tree().get_first_node_in_group("foreground")
@export var fire_point: Node2D
@export var laser_sounds: PackedScene
@export var gun_animator: AnimationPlayer
var gpu_particles_2d = preload("res://Scenes/Projectiles/bullet sparks.tscn")
@onready var ability_power_controller: Node = $AbilityPowerController

func _physics_process(delta):
	look_at(get_global_mouse_position())

func _input(event):
	if not ability_power_controller.powered:
		return
	if event.is_action_pressed("click") and SharedPlayerManager.request_energy_percentage() > 0:
		if gun_animator.is_playing():
			gun_animator.play("RESET")
		gun_animator.play("pew")
		target = get_global_mouse_position()
		var direction = (fire_point.global_position-target).normalized()
		parent.apply_central_impulse(direction*KICKBACK_POWER)
		var new_bullet = bullet.instantiate() as RigidBody2D
		foreground.add_child(new_bullet)
		var parts = gpu_particles_2d.instantiate() as GPUParticles2D
		foreground.add_child(parts)
		parts.global_position = fire_point.global_position
		parts.emitting = true
		new_bullet.global_position = fire_point.global_position
		new_bullet.apply_central_impulse(-direction * BULLET_POWER)
		var sounds = laser_sounds.instantiate()
		foreground.add_child(sounds)
		sounds.global_position = fire_point.global_position
		GameEvents.emit_energy_percent_changed(-ENERGY_COST)
