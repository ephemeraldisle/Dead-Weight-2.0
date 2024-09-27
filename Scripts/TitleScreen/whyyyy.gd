extends CharacterBody2D

@export var target_position: Node2D
var enabled = false
var last_position
var laster_position

func _physics_process(delta):
	if enabled:
		var velo = target_position.global_position - global_position
		var dir = velo.normalized()
		velocity = dir*250*delta*velo.length()
		move_and_slide()
		enabled = true
#		var tween = get_tree().create_tween()
#		tween.tween_property(self, "global_position", last_position, delta).from(laster_position).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
#		laster_position = last_position
#		last_position = target_position.global_position

func enable_physics():
	enabled = true
	last_position = target_position.global_position
	laster_position = last_position
