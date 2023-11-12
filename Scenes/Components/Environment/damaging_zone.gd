extends Area2D

@export var knockback_power = 500
@onready var impact_sound_for_player: AudioStreamPlayer2D = $ImpactSoundForPlayer


func _on_body_entered(body):
	if body.is_in_group("player") || body.is_in_group("tank") :
		impact_sound_for_player.play()
		var direction = global_position.direction_to(body.global_position)
		direction = Vector2.RIGHT.rotated(round(direction.angle() / TAU * 4) * TAU / 4).snapped(Vector2.ONE)
		if body.has_method("player_take_damage"):
			body.player_take_damage(direction*knockback_power*100)

	else:
		body.queue_free()
