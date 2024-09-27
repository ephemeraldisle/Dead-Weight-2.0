class_name ActionFinder
extends Area2D

const ARBITRARY_LARGE_NUMBER := 999999 
const ACTION_GROUP = "action"

var _nearby_actions := {}

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(ACTION_GROUP):
		area.display_prompt()
		_nearby_actions[area] = true
	
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group(ACTION_GROUP):
		area.hide_prompt()
		_nearby_actions[area] = false

func attempt_to_act() -> bool:
	var nearest := report_nearest()
	if nearest != null:
		if nearest.get_overlapping_bodies().size() > 0:
			nearest.do_interaction()
			return true
	return false


func report_nearest() -> Area2D:
	var nearest: Area2D = null
	var nearest_distance := ARBITRARY_LARGE_NUMBER
	for action in _nearby_actions:
		if _nearby_actions[action] == false:
			continue
		var distance = (action.global_position - global_position).length()
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = action
	return nearest


