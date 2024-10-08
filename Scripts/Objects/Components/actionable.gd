extends Area2D
class_name Actionable

var _acting := false

@export var action_holder: Node
@export var input_prompt: Node2D
@export var repeatable := true

func _ready():
	action_holder.action_finished.connect(interaction_finished)
	action_holder.action_reset.connect(reset)
	
func reset():
	input_prompt.modulate.a = g.FULL_OPACITY
	_acting = false

func display_prompt():
	input_prompt.visible = true
	
func hide_prompt():
	input_prompt.visible = false

func do_interaction():
	if _acting:
		return
	_acting = true
	action_holder.do_action()
		
func interaction_finished():
	if repeatable:
		_acting = false
	else:
		input_prompt.modulate.a = g.NO_OPACITY
