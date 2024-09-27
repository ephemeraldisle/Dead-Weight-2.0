class_name PlayerBumpNoiseTrigger
extends Area2D

const COOLDOWN_TIME = 0.5

var _colliding_entities: Array[Node2D] = []
var _cooldown_entities: Array[Node2D] = []

func _on_body_entered(body: Node2D) -> void:
	if not _colliding_entities.has(body) and not _cooldown_entities.has(body):
		_colliding_entities.append(body)
		SharedPlayerManager.play_thump_sound()


func _on_body_exited(body: Node2D) -> void:
	var index := _colliding_entities.find(body)
	if index != -1:
		_colliding_entities.remove_at(index)
		_cooldown_entities.append(body)
		_start_cooldown(body)

func _start_cooldown(body: Node2D) -> void:
	await get_tree().create_timer(COOLDOWN_TIME).timeout
	var index := _cooldown_entities.find(body)
	if index != -1:
		_cooldown_entities.remove_at(index)
