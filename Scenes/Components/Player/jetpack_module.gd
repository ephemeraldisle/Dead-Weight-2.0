extends Node2D

const WATER_COST_PER_FRAME = 0.00025
const JETPACK_POWER = 300
const IMPULSE_OFFSET = Vector2(0,0)

signal jetpacked

@onready var jet_particles = %JetParticles
@onready var parent = get_parent() as RigidBody2D
@export var water_manager: Node
@onready var noises = $noises
var never_jetpacked_before = true
@onready var ability_power_controller: Node = $AbilityPowerController as AbilityPowerController

func _physics_process(_delta):
	if not ability_power_controller.powered:
		return
	if not GameState.dialogue_happening and Input.is_action_pressed("jump") and SharedPlayerManager.request_water_percentage() > 0:
			if never_jetpacked_before:
				never_jetpacked_before = false
				jetpacked.emit()
			GameEvents.emit_water_collected(-WATER_COST_PER_FRAME)
			jet_particles.emitting = true
			parent.apply_central_impulse(-parent.transform.y*JETPACK_POWER)
			if not noises.playing:	
				noises.play()
	else:
		jet_particles.emitting = false
		noises.stop()
#		parent.constant_force = Vector2.ZERO
