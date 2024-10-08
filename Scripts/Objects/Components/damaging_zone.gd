extends Area2D
class_name DamagingZone

const DIRECTIONS := 4
const FULL_ROTATION := TAU

@export var knockback_power := 400.0
@export var knockback_multiplier := 50.0

@onready var impact_sound: AudioStreamPlayer2D = $ImpactSoundForPlayer

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.is_in_group("tank"):
		impact_sound.play()
		var knockback_direction := calculate_knockback_direction(body)
		if body.has_method("player_take_damage"):
			body.player_take_damage(knockback_direction * knockback_power * knockback_multiplier)
	else:
		body.queue_free()

func calculate_knockback_direction(body: Node2D) -> Vector2:
	var raw_direction := global_position.direction_to(body.global_position)
	var angle := raw_direction.angle()
	var snapped_angle = round(angle / FULL_ROTATION * DIRECTIONS) * FULL_ROTATION / DIRECTIONS
	return Vector2.RIGHT.rotated(snapped_angle).snapped(Vector2.ONE)
