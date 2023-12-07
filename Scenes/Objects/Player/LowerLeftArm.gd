extends RigidBody2D

@onready var pointer_rotator: Node2D = %PointerRotator
@onready var pointer: Node2D = %Pointer

func _physics_process(delta: float) -> void:
	pointer_rotator.look_at(get_global_mouse_position())
	look_at(pointer.global_position)
	rotation_degrees -= 90
#
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var distance_to_pointer = global_position.distance_to(pointer.global_position)
	if distance_to_pointer > 10:
		state.linear_velocity = global_position.direction_to(pointer.global_position)*10
