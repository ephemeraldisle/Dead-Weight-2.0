extends AnimatedSprite2D


func take_care_of_light(light: Light2D) -> void:
	light.reparent(self, false)
	light.global_position = global_position
	var tween = create_tween()
	tween.tween_property(light, "energy", 0, 0.5)
	await tween.finished
	queue_free()
