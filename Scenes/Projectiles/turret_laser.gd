extends AnimatableBody2D

@export var speed_factor: float = 10
@export var hit_effect: PackedScene
@onready var hit_sound: AudioStreamPlayer2D = $"Hit Sound"

var my_velocity = Vector2.ZERO
var my_light

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func program_projectile(velocity: Vector2, new_light: Light2D) -> void:
	constant_linear_velocity = velocity
	my_velocity = velocity
	my_light = new_light
	my_light.position = collision_shape_2d.position
	
func _physics_process(delta: float) -> void:
	if my_velocity != Vector2.ZERO:
		var collision = move_and_collide(my_velocity*delta*speed_factor)
		if collision:
			var collidee = collision.get_collider()
			if collidee.has_method("player_take_damage"):
				my_velocity = Vector2.RIGHT.rotated(round(my_velocity.angle() / TAU * 4) * TAU / 4).snapped(Vector2.ONE)
				collidee.player_take_damage(my_velocity*30000)
			hit_sound.play()
			var hit_eff = hit_effect.instantiate()
			hit_eff.scale *= 0.708
			get_parent().add_child(hit_eff)
			hit_sound.reparent(get_parent())
			hit_eff.rotation = rotation
			hit_eff.global_position = collision.get_position() - my_velocity*speed_factor*delta
			hit_eff.take_care_of_light(my_light)
			queue_free()

