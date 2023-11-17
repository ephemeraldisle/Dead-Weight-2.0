extends AnimatableBody2D

const HIT_EFFECT_SCALE = 0.708


@export var _speed_factor: float = 10
@export var hit_power = 30_000
@export var _hit_effect: PackedScene
@onready var _hit_sound: AudioStreamPlayer2D = $"Hit Sound"

var _my_velocity = Vector2.ZERO
var _my_light

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func program_projectile(velocity: Vector2, new_light: Light2D) -> void:
	constant_linear_velocity = velocity
	_my_velocity = velocity
	_my_light = new_light
	_my_light.position = collision_shape_2d.position


func _physics_process(delta: float) -> void:
	if _my_velocity != Vector2.ZERO:
		var collision = move_and_collide(_my_velocity * delta * _speed_factor)
		if collision:
			var collidee = collision.get_collider()
			if collidee.has_method("player_take_damage"):
				_my_velocity = (
					Vector2
					. RIGHT
					. rotated(round(_my_velocity.angle() / TAU * 4) * TAU / 4)
					. snapped(Vector2.ONE)
				)
				collidee.player_take_damage(_my_velocity * hit_power)
			_hit_sound.play()
			var hit_effect_instance = _hit_effect.instantiate()
			hit_effect_instance.scale *= HIT_EFFECT_SCALE
			get_parent().add_child(hit_effect_instance)
			_hit_sound.reparent(get_parent())
			hit_effect_instance.rotation = rotation
			hit_effect_instance.global_position = collision.get_position() - _my_velocity * _speed_factor * delta
			hit_effect_instance.take_care_of_light(_my_light)
			queue_free()
