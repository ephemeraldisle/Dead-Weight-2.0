extends AnimatedSprite2D

const MAX_LIGHT_POWER := 0.5

func take_care_of_light(light: Light2D) -> void:
	light.reparent(self, false)
	light.global_position = global_position
	var tween = create_tween()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER, MAX_LIGHT_POWER)
	await tween.finished
	queue_free()
