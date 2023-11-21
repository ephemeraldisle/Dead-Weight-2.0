extends Node
class_name SaveNode
signal action_finished
signal action_reset

var balln = preload("res://Scenes/UI/Dialogue/my_balloon.tscn")
var resource = preload("res://Dialogue/interactions.dialogue")
@export var title = "save_crystal"
@export var dialogue_placer: Control
@export var spawn_position: Vector2
@export var audio: AudioStreamPlayer2D

func do_action():
	#print("gonna act now thx")
	audio.play()
	GameEvents.emit_water_collected(1)
	GameEvents.emit_energy_collected(4)
	GameEvents.emit_full_heal()
	var balloon = balln.instantiate()
	GlobalCamera.add_child(balloon)	
	balloon.place_balloon(dialogue_placer.global_position)
	balloon.start(resource, title)
	await DialogueManager.dialogue_ended
	#print("dialogue is over now!")
	GameState.update_spawn_position(spawn_position)
	action_finished.emit()
