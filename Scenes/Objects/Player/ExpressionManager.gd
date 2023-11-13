extends Area2D

const MINIMUM_INTEREST_THRESHOLD = 200
const DEFAULT_MAX_INTEREST = 400
const DANGER_MULTIPLIER = 2
const SAFE_MULTIPLIER = 0.5
const PROJECTILE_PHYSICS_LAYER = 4
const PROJECTILE_MULTIPLIER = 1.5
const NON_PROJECTILE_MULTIPLIER = 0.75

const DANGER_EYE_SCALE = Vector2(1.1, 1.1)
const SAFE_EYE_SCALE = Vector2.ONE
const DANGER_PUPIL_SCALE = Vector2.ONE
const SAFE_PUPIL_SCALE = Vector2(0.9, 0.9)

const HURT_THRESHOLD = 1
const DAMAGE_ADDED_AGITATION = 1.5
const NON_DAMAGE_MAXIMUM = 0.99

const LERP_PERCENTAGE = 0.65
const MAGNET_TARGET_OFFSET = 100

@export var target_tracker: Node2D

var target_eye_size = SAFE_EYE_SCALE
var target_pupil_size = SAFE_PUPIL_SCALE
var desired_target_position = Vector2.ZERO
var current_target_position = Vector2.ZERO
var agitation = 0

@onready var tank: RigidBody2D = $".."
@onready var right_eye_holder = %RightEyeHolder
@onready var left_eye_holder = %LeftEyeHolder
@onready var eye_ball: Sprite2D = %EyeBall
@onready var eye_ball_2: Sprite2D = %EyeBall2
@onready var right_eye_complex: Node2D = %RightEyeComplex
@onready var left_eye_complex: Node2D = %LeftEyeComplex
@onready var expressions: AnimationPlayer = %Expressions


func _ready() -> void:
	tank.tank_hurt.connect(try_emotion.bind("hurt"))


#	get_tree().get_first_node_in_group("player").player_damaged.connect(try_emotion.bind("hurt"))


func get_closest_thing_of_interest() -> Vector2:
	var best_priority = MINIMUM_INTEREST_THRESHOLD
	var chosen_location = Vector2.ZERO
	var chosen_body
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		for body in bodies:
			var body_priority = (
				DEFAULT_MAX_INTEREST - body.global_position.distance_to(global_position)
			)
			if body.is_in_group("danger"):
				body_priority *= DANGER_MULTIPLIER
			else:
				body_priority *= SAFE_MULTIPLIER
			if body.get_collision_layer_value(PROJECTILE_PHYSICS_LAYER):
				body_priority *= PROJECTILE_MULTIPLIER
			else:
				body_priority *= NON_PROJECTILE_MULTIPLIER
			if body_priority > best_priority:
				best_priority = body_priority
				chosen_location = body.global_position
				chosen_body = body
	if !chosen_body:
		return chosen_location
	if chosen_body.is_in_group("danger"):
		target_eye_size = DANGER_EYE_SCALE
		target_pupil_size = DANGER_PUPIL_SCALE
		try_emotion("worried")
	else:
		target_eye_size = SAFE_EYE_SCALE
		target_pupil_size = SAFE_PUPIL_SCALE
	return chosen_location


func try_emotion(animation_name: String) -> void:
	if animation_name == "hurt":
		agitation = DAMAGE_ADDED_AGITATION
	elif agitation <= HURT_THRESHOLD:
		agitation = NON_DAMAGE_MAXIMUM


func _physics_process(delta: float) -> void:
	var location = get_closest_thing_of_interest()
	if location == Vector2.ZERO:
		location = to_global(get_local_mouse_position())

	eye_ball.look_at(Vector2.UP)
	eye_ball_2.look_at(Vector2.UP)
	right_eye_complex.scale = lerp(right_eye_complex.scale, target_eye_size, LERP_PERCENTAGE)
	left_eye_complex.scale = lerp(left_eye_complex.scale, target_eye_size, LERP_PERCENTAGE)
	eye_ball.scale = lerp(eye_ball.scale, target_pupil_size, LERP_PERCENTAGE)
	eye_ball_2.scale = lerp(eye_ball_2.scale, target_pupil_size, LERP_PERCENTAGE)
	target_tracker.global_position = current_target_position

	if tank.magnet_module.magnet_modifier > 0:
		expressions.play("concentrating")
		location = tank.global_position + tank.transform.y * MAGNET_TARGET_OFFSET
	elif agitation > 0:
		if agitation >= HURT_THRESHOLD:
			expressions.play("hurt")
		else:
			expressions.play("worried")
		agitation = max(agitation - delta, 0.0)
	else:
		expressions.play("RESET")

	desired_target_position = location
	current_target_position = lerp(
		current_target_position, desired_target_position, LERP_PERCENTAGE
	)

	right_eye_holder.look_at(current_target_position)
	left_eye_holder.look_at(current_target_position)
