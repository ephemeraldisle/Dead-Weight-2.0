extends Node

@onready var action_finder: Area2D = $"../ActionFinder"
@onready var ability_power_controller: Node = $AbilityPowerController

func _input(event):
	if not ability_power_controller.powered:
		return
	if event.is_action_pressed(g.INTERACT_BUTTON):
		if !action_finder.attempt_to_act():
			SharedPlayerManager.tank.action_finder.attempt_to_act()
