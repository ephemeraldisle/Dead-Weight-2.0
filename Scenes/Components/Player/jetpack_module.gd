extends Node2D

signal jetpacked

const WATER_COST_PER_FRAME = 0.00025
const JETPACK_POWER = 300
const IMPULSE_OFFSET = Vector2(0,0)

@export var water_manager: Node

@onready var _noises = $noises
@onready var _ability_power_controller: Node = $AbilityPowerController as AbilityPowerController
@onready var _jet_particles = %JetParticles
@onready var _parent = get_parent() as RigidBody2D

var never_jetpacked_before = true

func _physics_process(_delta):
	if not _ability_power_controller.powered:
		return
	if Input.is_action_pressed("jump") and SharedPlayerManager.request_water_percentage() > 0:
			if never_jetpacked_before:
				never_jetpacked_before = false
				jetpacked.emit()
			GameEvents.emit_water_collected(-WATER_COST_PER_FRAME)
			_jet_particles.emitting = true
			_parent.apply_central_impulse(-_parent.transform.y*JETPACK_POWER)
			if not _noises.playing:	
				_noises.play()
	else:
		_jet_particles.emitting = false
		_noises.stop()
#		_parent.constant_force = Vector2.ZERO
