class_name Projectile
extends AnimatableBody2D

const PLAYER_DAMAGE_METHOD := &"player_take_damage"

@export var speed_factor: float = 10.0
@export var hit_power: float = 30000.0
@export var hit_effect_scene: PackedScene
@export var knockback_arc_degrees: float = 120.0  # New export for knockback arc

var _velocity := Vector2.ZERO

@onready var hit_sound: AudioStreamPlayer2D = $"Hit Sound"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func program_projectile(velocity: Vector2, __: Light2D) -> void:
	constant_linear_velocity = velocity
	_velocity = velocity

func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		return
	
	var collision := move_and_collide(_velocity * delta * speed_factor)
	if collision:
		_handle_collision(collision, delta)

func _handle_collision(collision: KinematicCollision2D, delta: float) -> void:
	var collider := collision.get_collider()
	if collider.has_method(PLAYER_DAMAGE_METHOD):
		_apply_damage_to_player(collider, collision)
	
	_spawn_hit_effect(collision, delta)
	queue_free()

func _apply_damage_to_player(collider: Node, collision: KinematicCollision2D) -> void:
	var knockback_direction := _calculate_knockback_direction(collision)
	collider.call(PLAYER_DAMAGE_METHOD, knockback_direction * hit_power)

func _calculate_knockback_direction(collision: KinematicCollision2D) -> Vector2:
	var forward_direction := _velocity.normalized()
	var collision_normal := collision.get_normal()
	
	# Calculate the angle between the forward direction and the collision normal
	var angle := forward_direction.angle_to(collision_normal)
	
	# Clamp the angle to be within the specified arc
	var half_arc := deg_to_rad(knockback_arc_degrees) / 2
	angle = clamp(angle, -half_arc, half_arc)
	
	# Rotate the forward direction by the clamped angle
	return lerp(forward_direction, forward_direction.rotated(angle), 0.1)

func _spawn_hit_effect(collision: KinematicCollision2D, delta: float) -> void:
	var hit_effect := hit_effect_scene.instantiate()
	hit_effect.global_position = collision.get_position() - _velocity * speed_factor * delta
	
	var parent := get_parent()
	hit_sound.reparent(parent)
	parent.add_child(hit_effect)
	hit_sound.play()
