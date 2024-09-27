extends Node2D

signal player_rotated

const POWERED_TURN_SPEED := 500.0
const BASIC_TURN_SPEED := 250.0
const BASE_ENERGY_COST := 0.0015
const MAX_ENERGY_COST := 0.01
const MAX_MULTIPLIER := 10.0
const DEFAULT_MULTIPLIER := 1.0

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

	var rotation_input := Input.get_axis("left", "right")
	
	if rotation_input != 0:
		_handle_rotation(rotation_input)
	else:
		_reset_rotation()

	_check_tutorial_rotation(rotation_input)

func _handle_rotation(input: float) -> void:
	_parent.angular_damp = 0
	_is_rotating = true
	
	if SharedPlayerManager.request_energy_percentage() > 0:
		_apply_powered_rotation(input)
	else:
		_parent.apply_torque_impulse(BASIC_TURN_SPEED * input)
	
	_audio_player.play()

func _apply_powered_rotation(input: float) -> void:
	_parent.apply_torque_impulse(POWERED_TURN_SPEED * _rotation_multiplier * input)
	_rotation_multiplier = min(_rotation_multiplier + 1, MAX_MULTIPLIER)
	var energy_cost: float = min(_rotation_multiplier * BASE_ENERGY_COST, MAX_ENERGY_COST)
	GameEvents.emit_energy_percent_changed(-energy_cost)

func _reset_rotation() -> void:
	_is_rotating = false
	_rotation_multiplier = DEFAULT_MULTIPLIER
	_parent.angular_damp = _original_damp
	_audio_player.stop()

func _check_tutorial_rotation(input: float) -> void:
	if _monitoring_rotation:
		if input < 0:
			_rotated_left = true
		elif input > 0:
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
