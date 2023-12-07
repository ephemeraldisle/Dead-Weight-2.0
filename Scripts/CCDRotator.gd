extends Node2D

@export_range(-360, 360) var minimum_rotation = -360.0
@export_range(-360, 360) var maximum_rotation = 360.0

#@onready var original_rotation = rotation
#
func _ready() -> void:
	minimum_rotation = fmod(deg_to_rad(minimum_rotation) + 2 * PI, 2 * PI)
	maximum_rotation = fmod(deg_to_rad(maximum_rotation) + 2 * PI, 2 * PI)
