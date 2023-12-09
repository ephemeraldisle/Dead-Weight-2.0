extends Node2D

@export var root_node: Node2D
var bones : Array[Node2D]
var distances: Array
var target_node : Node2D
var target : Vector2
var iterations: int = 10
var tolerance := 0.5
var _max_length := 0.0

func _ready():
	collect_bones(self)
	for dist in distances:
		_max_length += dist
	if root_node.target != null:
		target_node = root_node.target

func _process(delta: float) -> void:
	if target_node != null:
		target = target_node.global_position
	else:
		target = get_global_mouse_position()
	solve()

func collect_bones(bone: Node2D):
	bones.append(bone)
	if bone != root_node:
		distances.append(bone.global_position.distance_to(bone.get_parent().global_position))
		collect_bones(bone.get_parent())

func solve():
	if target.distance_squared_to(root_node.global_position) > _max_length * _max_length:
		target = root_node.global_position + root_node.global_position.direction_to(target) * _max_length
#	target_node.global_position = target
	var iteration : int = 0
	while iteration < iterations:
		iteration += 1
		for i in range(bones.size()-1, 0, -1):
			var bone_position = bones[i].global_position
			var to_end = bone_position.direction_to(self.global_position)
			var to_target = bone_position.direction_to(target)
			var cos_theta = to_target.dot(to_end)
			var angle = acos(cos_theta)
			if to_end.cross(to_target) < 0:
				angle = -angle
			angle += bones[i].rotation
			angle = fmod(angle + 2*PI, 2*PI)
			var minimum = bones[i].minimum_rotation
			var maximum = bones[i].maximum_rotation
			
			if minimum > maximum:
				if angle < minimum and angle > maximum:
					if abs(minimum - angle) < abs(maximum - angle):
						angle = minimum
					else:
						angle = maximum
			else:
				angle = clamp(angle, minimum, maximum)
			bones[i].rotation = angle

			if self.global_position.distance_squared_to(target) < tolerance * tolerance:
				return
