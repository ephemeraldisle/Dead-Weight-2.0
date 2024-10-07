extends Node2D


const AUDIO_FADE_TIME := 0.25
const FIRST_PAUSE_TIME := 3.0
const SHORT_TIMEOUT := 0.5
const ACTUAL_BUBBLE = preload("res://Scenes/UI/Dialogue/my_balloon.tscn")
const DIALOGUE_RESOURCE = preload("res://Dialogue/MainScene.dialogue")
const COMPUTER_INTRO := "computer_intro"
const SCREENSHAKE_WARN := "screenshake_warning"
const BALLOON_APPEAR_ANIMATION := "Appear"
const MAIN_GAME_SCENE_PATH := "res://Scenes/Levels/main.tscn"

func _ready():
	AudioManager.soft_loop.play()
	AudioManager.fade_volume(AudioManager.soft_loop, g.SILENT_DB, g.NORMAL_DB, AUDIO_FADE_TIME)
	var balloon = ACTUAL_BUBBLE.instantiate()
	await get_tree().create_timer(FIRST_PAUSE_TIME).timeout
	GlobalCamera.follow_pos(g.HALF_WINDOW_SIZE)
	add_child(balloon)
	if !GameState.options_visited:
		var animator = balloon.animation_player as AnimationPlayer
		balloon.start(DIALOGUE_RESOURCE, SCREENSHAKE_WARN)
		await DialogueManager.dialogue_ended
		await animator.animation_finished
		await get_tree().create_timer(SHORT_TIMEOUT).timeout	
		balloon.animation_player.play(BALLOON_APPEAR_ANIMATION)
	balloon.start(DIALOGUE_RESOURCE, COMPUTER_INTRO)
	await DialogueManager.dialogue_ended
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	GameState.introduction_watched = true
	SaveManager.update_game_states()
	get_tree().change_scene_to_file(MAIN_GAME_SCENE_PATH)
