extends Node
@onready var ability_power_controller: Node = $AbilityPowerController as AbilityPowerController


func _input(event):
	if not ability_power_controller.powered:
		return
	if GameState.state.abilities.death:
		if event.is_action_pressed("restart"):
			SharedPlayerManager.die()
