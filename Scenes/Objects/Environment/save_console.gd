extends StaticBody2D

signal action_finished
signal action_reset

@export var title := "save_crystal"
@export var dialogue_placer: Control
@export var spawn_position: Node2D
@export var audio: AudioStreamPlayer2D

var balln = preload("res://Scenes/UI/Dialogue/my_balloon.tscn")
var resource = preload("res://Dialogue/interactions.dialogue")

@onready var ping_animation = $PingAnimation

func do_action():
	#print("gonna act now thx")
	audio.play()
	
	GameEvents.emit_water_collected(g.MAX_WATER_PERCENT)
	GameEvents.emit_energy_collected(g.MAX_ENERGY_PERCENT)
	GameEvents.emit_full_heal()

	var balloon = balln.instantiate()
	GlobalCamera.add_child(balloon)	
	balloon.place_balloon(dialogue_placer.global_position)
	balloon.start(resource, title)
	await DialogueManager.dialogue_ended
	#print("dialogue is over now!")
	GameState.update_spawn_position(spawn_position)
	GameState.total_save()
	action_finished.emit()
