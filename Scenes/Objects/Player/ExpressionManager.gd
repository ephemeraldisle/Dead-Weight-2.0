extends Area2D

const MINIMUM_INTEREST_THRESHOLD := 200
const DEFAULT_MAX_INTEREST := 400
const PROJECTILE_PHYSICS_LAYER := 4

const DANGER_MULTIPLIER := 2.0
const SAFE_MULTIPLIER := 0.5
const PROJECTILE_MULTIPLIER := 1.5
const NON_PROJECTILE_MULTIPLIER := 0.75

const DANGER_EYE_SCALE := Vector2(1.1, 1.1)
const SAFE_EYE_SCALE := Vector2.ONE
const DANGER_PUPIL_SCALE := Vector2.ONE
const SAFE_PUPIL_SCALE := Vector2(0.9, 0.9)

const HURT_THRESHOLD := 1
const DAMAGE_ADDED_AGITATION := 1.5
const NON_DAMAGE_MAXIMUM := 0.99

const LERP_PERCENTAGE := 0.65
const MAGNET_TARGET_OFFSET := 100


const PLAYER_GROUP := &"player"
const DANGER_GROUP := &"danger"

const EMOTION_HURT := &"hurt"
const EMOTION_WORRIED := &"worried"
const EMOTION_CONCENTRATING := &"concentrating"
const EMOTION_RESET := &"RESET"

@export var target_tracker: Node2D

var _target_eye_size := SAFE_EYE_SCALE
var _target_pupil_size := SAFE_PUPIL_SCALE
var _desired_target_position := Vector2.ZERO
var _current_target_position := Vector2.ZERO
var _agitation := 0.0

@onready var _tank: RigidBody2D = $".."
@onready var _right_eye_holder := %RightEyeHolder
@onready var _left_eye_holder := %LeftEyeHolder
@onready var _eye_ball: Sprite2D = %EyeBall
@onready var _eye_ball_2: Sprite2D = %EyeBall2
@onready var _right_eye_complex: Node2D = %RightEyeComplex
@onready var _left_eye_complex: Node2D = %LeftEyeComplex
@onready var _expressions: AnimationPlayer = %Expressions

func _ready() -> void:
	_tank.tank_hurt.connect(_try_emotion.bind(EMOTION_HURT))
	get_tree().get_first_node_in_group(PLAYER_GROUP).player_damaged.connect(_try_emotion.bind(EMOTION_HURT))


func _physics_process(delta: float) -> void:
	_update_target_position()
	_update_eye_appearance()
	_update_expressions(delta)
	target_tracker.global_position = _current_target_position

func _update_target_position() -> void:
	var target = _get_closest_thing_of_interest()
	if target == Vector2.ZERO:
		target = to_global(get_local_mouse_position())
	
	if _tank.magnet_module.magnet_modifier > 0:
		target = _tank.global_position + _tank.transform.y * MAGNET_TARGET_OFFSET
	
	_desired_target_position = target
	_current_target_position = lerp(_current_target_position, _desired_target_position, LERP_PERCENTAGE)


func _get_closest_thing_of_interest() -> Vector2:
	var best_priority := MINIMUM_INTEREST_THRESHOLD
	var chosen_location := Vector2.ZERO
	var chosen_body: Node = null
	var bodies := get_overlapping_bodies()
	
	for body in bodies:
		var body_priority = _calculate_body_priority(body)
		if body_priority > best_priority:
			best_priority = body_priority
			chosen_location = body.global_position
			chosen_body = body
			
	if chosen_body:
		_update_eye_state(chosen_body)

	return chosen_location

func _calculate_body_priority(body: Node) -> float:
	var distance_priority = DEFAULT_MAX_INTEREST - body.global_position.distance_to(global_position)
	var danger_multiplier = DANGER_MULTIPLIER if body.is_in_group(DANGER_GROUP) else SAFE_MULTIPLIER
	var projectile_multiplier = PROJECTILE_MULTIPLIER if body.get_collision_layer_value(PROJECTILE_PHYSICS_LAYER) else NON_PROJECTILE_MULTIPLIER
	return distance_priority * danger_multiplier * projectile_multiplier


func _update_eye_state(body: Node) -> void:
	if body.is_in_group(DANGER_GROUP):
		_target_eye_size = DANGER_EYE_SCALE
		_target_pupil_size = DANGER_PUPIL_SCALE
		_try_emotion(EMOTION_WORRIED)
	else:
		_target_eye_size = SAFE_EYE_SCALE
		_target_pupil_size = SAFE_PUPIL_SCALE


func _try_emotion(animation_name: String) -> void:
	match animation_name:
		EMOTION_HURT:
			_agitation = DAMAGE_ADDED_AGITATION
		_:
			if _agitation <= HURT_THRESHOLD:
				_agitation = NON_DAMAGE_MAXIMUM


func _update_eye_appearance() -> void:
	_eye_ball.look_at(Vector2.UP)
	_eye_ball_2.look_at(Vector2.UP)
	_right_eye_complex.scale = lerp(_right_eye_complex.scale, _target_eye_size, LERP_PERCENTAGE)
	_left_eye_complex.scale = lerp(_left_eye_complex.scale, _target_eye_size, LERP_PERCENTAGE)
	_eye_ball.scale = lerp(_eye_ball.scale, _target_pupil_size, LERP_PERCENTAGE)
	_eye_ball_2.scale = lerp(_eye_ball_2.scale, _target_pupil_size, LERP_PERCENTAGE)
	_right_eye_holder.look_at(_current_target_position)
	_left_eye_holder.look_at(_current_target_position)


func _update_expressions(delta: float) -> void:
	if _tank.magnet_module.magnet_modifier > 0:
		_expressions.play(EMOTION_CONCENTRATING)
	elif _agitation > 0:
		_expressions.play(EMOTION_HURT if _agitation >= HURT_THRESHOLD else EMOTION_WORRIED)
		_agitation = max(_agitation - delta, 0.0)
	else:
		_expressions.play(EMOTION_RESET)

