extends Node2D
@onready var rope_holder: Node2D = $RopeHolder
@onready var player: RigidBody2D = $Player
@onready var tank: RigidBody2D = $Tank


func _ready() -> void:
	rope_holder.global_position = player.attachment_point.global_position
	tank.global_position = player.attachment_point.global_position + Vector2(0,98)
	rope_holder.set_origin_attach(player.get_path())
	rope_holder.set_end_attach(tank.get_path())
