extends Node
@onready var ability_power_controller: Node = $AbilityPowerController

func _input(event):
	if GameState.dialogue_happening or not ability_power_controller.powered:
		return
#	if event.is_action_pressed("interact"):
#		if !action_finder.attempt_to_act():
#			SharedPlayerManager.tank.action_finder.attempt_to_act()
