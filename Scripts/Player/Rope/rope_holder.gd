class_name RopeHolder
extends Node2D

const INITIAL_DELAY := 0.5
const ANIMATION_DELAY := 0.25
const SEGMENT_DELAY := 0.1

const SEGMENT_NAME := "RopeSegment"
const START_ANIMATION_METHOD := "start_animation"

@export var origin_attach: PhysicsBody2D
@export var end_attach: PhysicsBody2D
@export var enable_animation := false

@onready var origin_pin: Joint2D = %OriginPin
@onready var end_pin: Joint2D = %EndPin


func _ready():
	await get_tree().create_timer(INITIAL_DELAY, false, true).timeout
	if origin_attach!= null:
		set_origin_attach(origin_attach.get_path())
	if end_attach!= null:
		set_end_attach(end_attach.get_path())
		
	if enable_animation:
		animate_segments()


func set_origin_attach(node_path: NodePath) -> void:
	origin_pin.set_node_a(node_path)


func set_end_attach(node_path: NodePath) -> void:
	end_pin.set_node_b(node_path)

func animate_segments() -> void:
	var segments = find_children("", SEGMENT_NAME)
	segments.reverse()
	await get_tree().create_timer(ANIMATION_DELAY, false, true).timeout
	for segment in segments:		
		if segment.has_method(START_ANIMATION_METHOD):
			segment.start_animation()
		await get_tree().create_timer(SEGMENT_DELAY, false, true).timeout
