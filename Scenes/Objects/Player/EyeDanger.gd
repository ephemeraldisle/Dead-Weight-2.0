extends Area2D
@onready var right_eye_holder = %RightEyeHolder
@onready var left_eye_holder = %LeftEyeHolder
@onready var eye_ball: Sprite2D = %EyeBall
@onready var eye_ball_2: Sprite2D = %EyeBall2
@onready var upper_lid: Sprite2D = %"upper lid"
@onready var lower_lid: Sprite2D = %"lower lid"
@onready var right_eye_complex: Node2D = %RightEyeComplex
@onready var left_eye_complex: Node2D = %LeftEyeComplex
@onready var expressions: AnimationPlayer = %Expressions

@export var gazer: Node2D
var target_eye_size = Vector2.ONE
var target_pupil_size = Vector2(0.9,0.9)
var desired_target_position = Vector2.ZERO
var current_target_position = Vector2.ZERO
var agitation = 0
@onready var tank: RigidBody2D = $".."

func _ready() -> void:
	tank.tank_hurt.connect(try_emotion.bind("hurt"))
	get_tree().get_first_node_in_group("player").player_damaged.connect(try_emotion.bind("hurt"))


func get_closest_thing_of_interest() -> Vector2:
	var best_priority = 200
	var chosen_location = Vector2.ZERO
	var chosen_body
	var bodies = get_overlapping_bodies()
	if bodies.size() > 0:
		for body in bodies:
			var body_priority = 400 - body.global_position.distance_to(global_position)
#			print(body_priority)
			if body.is_in_group("danger"):
				body_priority *= 2
			else:
				body_priority *= 0.5
			if body.get_collision_layer_value(4):
				body_priority *= 1.5
			else:
				body_priority *= 0.75
			if body_priority > best_priority:
				best_priority = body_priority
				chosen_location = body.global_position
				chosen_body = body
	if !chosen_body:
		return chosen_location
	if chosen_body.is_in_group("danger"):
		target_eye_size = Vector2(1.1, 1.1)
		target_pupil_size = Vector2.ONE
		try_emotion("worried")
	else:
		target_eye_size = Vector2.ONE
		target_pupil_size = Vector2(0.9,0.9)
	return chosen_location

func try_emotion(animation_name: String) -> void:
	if animation_name == "hurt":
		agitation = 1.5
	elif agitation <= 1:
		agitation = 0.99

			
func _physics_process(delta: float) -> void:
	var location = get_closest_thing_of_interest()
	if location == Vector2.ZERO:
		location = to_global(get_local_mouse_position())
	
	eye_ball.look_at(Vector2.UP)
	eye_ball_2.look_at(Vector2.UP)
	right_eye_complex.scale = lerp(right_eye_complex.scale, target_eye_size, 0.65)
	left_eye_complex.scale = lerp(left_eye_complex.scale, target_eye_size,  0.65)
	eye_ball.scale = lerp(eye_ball.scale, target_pupil_size,  0.65)
	eye_ball_2.scale = lerp(eye_ball_2.scale, target_pupil_size,  0.65)
	gazer.global_position = current_target_position
	
	
	
	if tank.magnet_modifier > 0:
		expressions.play("concentrating")
		location = tank.global_position + tank.transform.y*100
	elif agitation > 0:
		if agitation >= 1:
			expressions.play("hurt")
		else:
			expressions.play("worried")
		agitation = max(agitation-delta, 0.0)
	else:
		expressions.play("RESET")
	
	desired_target_position = location
	current_target_position = lerp(current_target_position, desired_target_position, 0.65)
	
	right_eye_holder.look_at(current_target_position)	
	left_eye_holder.look_at(current_target_position)		
