class_name RopeSegment
extends RigidBody2D

const PUMP_ANIMATION := "pump"

@onready var animation_player := $AnimationPlayer
@onready var ping_animation: Node2D = $PingAnimation if has_node("PingAnimation") else null

func start_animation():
	animation_player.play(PUMP_ANIMATION)
