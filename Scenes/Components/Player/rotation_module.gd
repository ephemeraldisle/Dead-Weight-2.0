extends Node2D

signal player_rotated

const POWERED_TURN_SPEED := 500.0
const BASIC_TURN_SPEED := 250.0
const BASE_ENERGY_COST := 0.0015
const MAX_ENERGY_COST := 0.01
const MAX_MULTIPLIER := 10.0
const DEFAULT_MULTIPLIER := 1.0
const NEUTRAL_INPUT := 0.0
const NO_ANGULAR_DAMP := 0.0
const NO_ENERGY := 0.0
const MULTIPLIER_GAIN_PER_FRAME := 1

var _rotation_multiplier := DEFAULT_MULTIPLIER
var _is_rotating := false
var _monitoring_rotation := false
var _rotated_left := false
var _rotated_right := false

@onready var _parent := get_parent() as RigidBody2D
@onready var _ability_power_controller: Node = $AbilityPowerController
@onready var _original_damp := _parent.angular_damp
@onready var _audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _physics_process(_delta: float) -> void:
	if GameState.introduction_running or not _ability_power_controller.powered:
		return

	var rotation_input := Input.get_axis(g.LEFT_BUTTON, g.RIGHT_BUTTON)
	
	if rotation_input != NEUTRAL_INPUT:
		_handle_rotation(rotation_input)
	else:
		_reset_rotation()

	_check_tutorial_rotation(rotation_input)

func _handle_rotation(input: float) -> void:
	_parent.angular_damp = NO_ANGULAR_DAMP
	_is_rotating = true
	
	if SharedPlayerManager.request_energy_percentage() > NO_ENERGY:
		_apply_powered_rotation(input)
	else:
		_parent.apply_torque_impulse(BASIC_TURN_SPEED * input)
	
	if not _audio_player.playing:
		_audio_player.play()

func _apply_powered_rotation(input: float) -> void:
	_parent.apply_torque_impulse(POWERED_TURN_SPEED * _rotation_multiplier * input)
	_rotation_multiplier = min(_rotation_multiplier + MULTIPLIER_GAIN_PER_FRAME, MAX_MULTIPLIER)
	var energy_cost: float = min(_rotation_multiplier * BASE_ENERGY_COST, MAX_ENERGY_COST)
	GameEvents.emit_energy_percent_changed(-energy_cost)

func _reset_rotation() -> void:
	_is_rotating = false
	_rotation_multiplier = DEFAULT_MULTIPLIER
	_parent.angular_damp = _original_damp
	_audio_player.stop()

func _check_tutorial_rotation(input: float) -> void:
	if not _monitoring_rotation: 
		return
		
	if input < NEUTRAL_INPUT:
		_rotated_left = true
	elif input > NEUTRAL_INPUT:
		_rotated_right = true
	
	if _rotated_left and _rotated_right:
		player_rotated.emit()
		_monitoring_rotation = false
		_rotated_left = false
		_rotated_right = false

func start_monitoring_rotation() -> void:
	_monitoring_rotation = true
	_rotated_left = false
	_rotated_right = false
