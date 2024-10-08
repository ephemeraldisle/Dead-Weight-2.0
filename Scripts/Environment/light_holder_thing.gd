extends Node2D

enum LightMode {Alarm, Flicker, Steady}

const FLICKER_SPEED_SCALE := 0.5

@onready var the_light: PointLight2D = %TheLight
@onready var light_bulb: Sprite2D = %LightBulb
@onready var animation_player: AnimationPlayer = %AnimationPlayer

@export var delay_time: float
@export var light_color: Color
@export var light_mode: LightMode

func _ready() -> void:
	the_light.color = light_color
	light_bulb.self_modulate = light_color
	await get_tree().create_timer(delay_time, false, true).timeout
	if light_mode == LightMode.Flicker:
		animation_player.speed_scale = FLICKER_SPEED_SCALE
	animation_player.play(LightMode.keys()[light_mode])
