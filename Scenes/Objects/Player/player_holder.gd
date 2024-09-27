class_name PlayerHolder
extends Node2D

const TANK_HEIGHT_OFFSET := Vector2(0, 98)

@onready var rope_holder: RopeHolder = $RopeHolder
@onready var player: Player = $Player
@onready var tank: Tank = $Tank

func _ready() -> void:
	rope_holder.global_position = player.attachment_point.global_position
	tank.global_position = player.attachment_point.global_position + TANK_HEIGHT_OFFSET
	rope_holder.set_origin_attach(player.get_path())
	rope_holder.set_end_attach(tank.get_path())
