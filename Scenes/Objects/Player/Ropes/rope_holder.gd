extends Node2D
class_name RopeHolder

@onready var origin_pin = %OriginPin as Joint2D
@onready var end_pin = %EndPin as Joint2D

@export var origin_attach: PhysicsBody2D
@export var end_attach: PhysicsBody2D

@export var enable_animation = false


func _ready():
	await get_tree().create_timer(0.5, false, true).timeout
	if origin_attach!= null:
		set_origin_attach(origin_attach.get_path())
	if end_attach!= null:
		set_end_attach(end_attach.get_path())
		
	if enable_animation:
		var segments = find_children("", "RigidBody2D")
		segments.reverse()
		await get_tree().create_timer(0.25, false, true).timeout
		for segment in segments:		
			segment.start_animation()
			await get_tree().create_timer(0.1, false, true).timeout
			

func set_origin_attach(node_path: NodePath):
	origin_pin.set_node_a(node_path)
	#print(origin_pin.node_a)


func set_end_attach(node_path: NodePath):
	end_pin.set_node_b(node_path)
	#print(end_pin.node_b)
