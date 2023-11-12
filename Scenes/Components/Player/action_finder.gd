extends Area2D

var nearby_actions = {}

func _on_area_entered(area: Area2D):
	if area.is_in_group("action"):
		area.display_prompt()
		nearby_actions[area] = true
	
func _on_area_exited(area):
	if area.is_in_group("action"):
		area.hide_prompt()
		nearby_actions[area] = false

func report_nearest():
	var nearest = null
	var nearest_distance = 99999
	for action in nearby_actions:
		if nearby_actions[action] == false:
			continue
		var distance = (action.global_position - global_position).length()
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = action
	return nearest

func attempt_to_act():
	var nearest = report_nearest() as Area2D
	if nearest != null:		
		if nearest.get_overlapping_bodies().size() > 0:
			nearest.do_interaction()
			return true
	return false
