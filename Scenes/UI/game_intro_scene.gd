extends Node2D

const ActualBubble = preload("res://Scenes/UI/Dialogue/my_balloon.tscn")
var resource = preload("res://Dialogue/MainScene.dialogue")
var title = "computer_intro"


func _ready():
	AudioManager.soft_loop.play()
	AudioManager.fade_volume(AudioManager.soft_loop, -80, 0, 0.25)
	var balloon = ActualBubble.instantiate()
	await get_tree().create_timer(3).timeout
	GlobalCamera.follow_pos(Vector2(640, 360))
	add_child(balloon)
	if !GameState.options_visited:
		var animator = balloon.animation_player as AnimationPlayer
		balloon.start(resource, "screenshake_warning")
		await DialogueManager.dialogue_ended
		await animator.animation_finished
		await get_tree().create_timer(0.5).timeout	
		balloon.animation_player.play("Appear")
	balloon.start(resource, title)
	await DialogueManager.dialogue_ended
	ScreenTransition.transition()
	await ScreenTransition.transitioned_halfway
	GameState.introduction_watched = true
	SaveManager.update_game_states()
	get_tree().change_scene_to_file("res://Scenes/Levels/main.tscn")
