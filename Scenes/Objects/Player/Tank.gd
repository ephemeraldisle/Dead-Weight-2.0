extends RigidBody2D

signal tank_hurt

@export var raycasts: Array[RayCast2D]
@export var magnet_particles: Array[GPUParticles2D]

var grounded = false
var idle = false
var recent_damage = false

@onready var ping_animation = $PingAnimation
@onready var action_finder = $ActionFinder
@onready var water_drops: GPUParticles2D = %WaterDrops


func _ready() -> void:
	SharedPlayerManager.tank = self


func _physics_process(_delta) -> void:
	if GameState.dialogue_happening:
		linear_damp = 30
		angular_damp = 30
	elif !grounded:
		linear_damp = 0
		angular_damp = 3


func player_take_damage(impulse: Vector2) -> void:
	if recent_damage:
		return
	tank_hurt.emit()
	GlobalCamera.add_trauma(0.5)
	recent_damage = true
	get_tree().paused = true
	await get_tree().create_timer(0.05).timeout
	get_tree().paused = false
#	if shielded:
#		remove_shield()
##	else:
#		apply_central_impulse(impulse*0.5)
#		shield_down_time = Time.get_unix_time_from_system()
#		water_drops.emitting = true
#		GameEvents.emit_water_collected(-randfn(0.1, 0.02))
	await get_tree().create_timer(1, false, true).timeout
	recent_damage = false
