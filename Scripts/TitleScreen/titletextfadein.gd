extends Label

const LONG_FADE_TIME := 2.0
const SHORT_FADE_TIME := 0.75
const TRANSITION_FADE_TIME := 0.5
const MAIN_MENU_SCENE := "res://Scenes/UI/main_menu.tscn"
const TRANSITION_ANIMATION := &"advance"
const PARTIAL_OPACITY := 0.75

var shouldnt_be_my_responsibility := false
var ending_started := false
var tween: Tween

@onready var player_animator := $"../PlayerAnimator"
@onready var audio_stream_player := $AudioStreamPlayer

func do_the_thing() -> void:
	shouldnt_be_my_responsibility = true
	tween = get_tree().create_tween()
	tween.set_loops()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, LONG_FADE_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, g.OPACITY, PARTIAL_OPACITY, SHORT_FADE_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, SHORT_FADE_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, g.OPACITY, PARTIAL_OPACITY, SHORT_FADE_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, SHORT_FADE_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, LONG_FADE_TIME).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)

func _unhandled_input(event: InputEvent) -> void:
	if !shouldnt_be_my_responsibility or ending_started:
		return
	if event.is_pressed():
		ending_started = true
		player_animator.play(TRANSITION_ANIMATION)
		audio_stream_player.play()

func transition_time() -> void:
	if tween.is_valid():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, TRANSITION_FADE_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	AudioManager.switch_to_menu_song()
	await tween.finished
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
