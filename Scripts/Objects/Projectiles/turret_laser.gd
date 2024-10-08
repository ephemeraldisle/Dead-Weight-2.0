class_name TurretLaser
extends AnimatableBody2D

const HIT_EFFECT_SCALE := 0.708
const PLAYER_DAMAGE_METHOD := &"player_take_damage"
const VECTOR_SNAP := Vector2.ONE
const ROTATION_STEPS := 4

@export var speed_factor: float = 10.0
@export var hit_power: float = 30000.0
@export var hit_effect_scene: PackedScene

var _velocity := Vector2.ZERO
var _light: Light2D

@onready var hit_sound: AudioStreamPlayer2D = $"Hit Sound"
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func program_projectile(velocity: Vector2, new_light: Light2D) -> void:
	constant_linear_velocity = velocity
	_velocity = velocity
	_light = new_light
	_light.position = collision_shape.position

func _physics_process(delta: float) -> void:
	if _velocity == Vector2.ZERO:
		return
	
	var collision := move_and_collide(_velocity * delta * speed_factor)
	if collision:
		_handle_collision(collision, delta)

func _handle_collision(collision: KinematicCollision2D, delta: float) -> void:
	var collider := collision.get_collider()
	if collider.has_method(PLAYER_DAMAGE_METHOD):
		_apply_damage_to_player(collider)
	
	_spawn_hit_effect(collision, delta)
	queue_free()

func _apply_damage_to_player(collider: Node) -> void:
	var damage_direction := _calculate_damage_direction()
	collider.call(PLAYER_DAMAGE_METHOD, damage_direction * hit_power)

func _calculate_damage_direction() -> Vector2:
	var angle = round(_velocity.angle() / TAU * ROTATION_STEPS) * TAU / ROTATION_STEPS
	return Vector2.RIGHT.rotated(angle).snapped(VECTOR_SNAP)

func _spawn_hit_effect(collision: KinematicCollision2D, delta: float) -> void:
	var hit_effect := hit_effect_scene.instantiate()
	hit_effect.scale *= HIT_EFFECT_SCALE
	hit_effect.rotation = rotation
	hit_effect.global_position = collision.get_position() - _velocity * speed_factor * delta
	
	var parent := get_parent()
	parent.add_child(hit_effect)
	hit_sound.reparent(parent)
	hit_sound.play()
	
	hit_effect.take_care_of_light(_light)
