extends Node2D

const POWERED_TURN_SPEED = 500
const BASIC_TURN_SPEED = 250
const BASE_ENERGY_COST = 0.0015
const MAX_ENERGY_COST = 0.01
const MAX_MULTIPLIER = 10
const DEFAULT_MULTIPLIER = 1


signal player_rotated
var left_rotation = false
var right_rotation = false
var monitoring_rotation = false

var left_multiplier = DEFAULT_MULTIPLIER
var right_multiplier = DEFAULT_MULTIPLIER
var rotating = false

@onready var parent = get_parent() as RigidBody2D
@onready var ability_power_controller: Node = $AbilityPowerController
@onready var original_damp = parent.angular_damp
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(_delta):
	if GameState.introduction_running or not ability_power_controller.powered:
		return	

	rotating = false
	if Input.is_action_pressed("left"):
		if monitoring_rotation:
			left_rotation = true
		parent.angular_damp = 0
		rotating = true
		if SharedPlayerManager.request_energy_percentage() > 0:
			parent.apply_torque_impulse(-POWERED_TURN_SPEED*left_multiplier)
			left_multiplier = min(left_multiplier+1, MAX_MULTIPLIER)
			GameEvents.emit_energy_percent_changed(-min(left_multiplier*BASE_ENERGY_COST, MAX_ENERGY_COST))
		else:
			parent.apply_torque_impulse(-BASIC_TURN_SPEED)
	else:
		left_multiplier = DEFAULT_MULTIPLIER
	if Input.is_action_pressed("right"):
		if monitoring_rotation:
			right_rotation = true
		parent.angular_damp = 0
		rotating = true
		if SharedPlayerManager.request_energy_percentage() > 0:
			parent.apply_torque_impulse(POWERED_TURN_SPEED*right_multiplier)
			right_multiplier = min(right_multiplier+1, MAX_MULTIPLIER)
			GameEvents.emit_energy_percent_changed(-min(right_multiplier*BASE_ENERGY_COST, MAX_ENERGY_COST))
		else: 
			parent.apply_torque_impulse(BASIC_TURN_SPEED)
	else:
		right_multiplier = DEFAULT_MULTIPLIER
	
	if rotating:
		audio_stream_player_2d.play()
	else:
		audio_stream_player_2d.stop()
		parent.angular_damp = original_damp
	
	if monitoring_rotation and left_rotation and right_rotation:
		#print("we did it! we rotated!")
		player_rotated.emit()
		monitoring_rotation = false
