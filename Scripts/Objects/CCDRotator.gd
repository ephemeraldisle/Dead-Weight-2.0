extends Node2D

const FULL_ROTATION := TAU

@export_range(-360, 360) var minimum_rotation := -360.0
@export_range(-360, 360) var maximum_rotation := 360.0
@export var target: Node2D

func _ready() -> void:
	minimum_rotation = fmod(deg_to_rad(minimum_rotation) + FULL_ROTATION, FULL_ROTATION)
	maximum_rotation = fmod(deg_to_rad(maximum_rotation) + FULL_ROTATION, FULL_ROTATION)
