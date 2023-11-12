extends Area2D
class_name Actionable

@export var action_holder: Node
@export var input_prompt: Node2D
@export var repeatable = true

var acting = false

func _ready():
	action_holder.action_finished.connect(interaction_finished)
	action_holder.action_reset.connect(reset)
	
func reset():
	input_prompt.modulate.a = 1
	acting = false

func display_prompt():
	input_prompt.visible = true
	
func hide_prompt():
	input_prompt.visible = false

func do_interaction():
	if acting:
		return
	acting = true
	action_holder.do_action()
		
func interaction_finished():
	if repeatable:
		acting = false
	else:
		input_prompt.modulate.a = 0
