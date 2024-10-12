class_name TurretLaser
extends Projectile

const HIT_EFFECT_SCALE := 0.708
const LIGHT_CLEANUP_METHOD := "take_care_of_light"

var _light: Light2D

func program_projectile(velocity: Vector2, new_light: Light2D) -> void:
	super.program_projectile(velocity, new_light)
	_light = new_light
	_light.position = collision_shape.position

func _spawn_hit_effect(collision: KinematicCollision2D, delta: float) -> void:
	super._spawn_hit_effect(collision, delta)
	
	var hit_effect = get_parent().get_child(-1)
	hit_effect.scale *= HIT_EFFECT_SCALE
	hit_effect.rotation = rotation
	
	if _light and hit_effect.has_method(LIGHT_CLEANUP_METHOD):
		hit_effect.take_care_of_light(_light)
