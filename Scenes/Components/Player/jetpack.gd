extends Node2D

signal jetpacked

@onready var jet_particles = %JetParticles
@onready var parent = get_parent() as RigidBody2D
@export var water_manager: Node
@onready var noises = $noises
var never_jetpacked_before = true


func _physics_process(delta):
	if GameState.introduction_running && !GameState.jetpack_enabled:
		return
	if !GameState.dialogue_happening && Input.is_action_pressed("jump") && water_manager.water_percent > 0:
			if never_jetpacked_before:
				never_jetpacked_before = false
				jetpacked.emit()
			water_manager.change_water(-0.00025)
			jet_particles.emitting = true
			parent.apply_impulse(-parent.transform.y*300, Vector2(-1,0))
			if !noises.playing:	
				noises.play()
	else:
		jet_particles.emitting = false
		noises.stop()
#		parent.constant_force = Vector2.ZERO
