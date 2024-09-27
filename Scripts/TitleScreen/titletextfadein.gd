extends Label

var shouldnt_be_my_responsibility = false
@onready var player_animator = $"../PlayerAnimator"
var ending_started = false
@onready var tween
@onready var audio_stream_player = $AudioStreamPlayer

func do_the_thing():
	shouldnt_be_my_responsibility = true
	tween= get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, "modulate:a", 1, 2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.75, 0.75).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1, 0.75).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.75, 0.75).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 1, 0.75).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0, 2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)

func _unhandled_input(event):
	if !shouldnt_be_my_responsibility or ending_started:
		return
	if event.is_pressed():
		ending_started = true
		player_animator.play("advance")
		audio_stream_player.play()

func transition_time():
	if tween.is_valid():
		tween.kill()
	tween = get_tree().create_tween() as Tween
	tween.tween_property(self, "modulate:a", 0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	AudioManager.switch_to_menu_song()
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
