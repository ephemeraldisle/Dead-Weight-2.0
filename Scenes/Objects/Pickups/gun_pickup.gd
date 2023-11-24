extends Node2D

#@export var sounds: PackedScene

@onready var sprite_2d = $Sprite2D

var is_collected = false
var collector
var tween

signal collected

func _ready():
	$Area2D.area_entered.connect(on_area_entered)
#	if GameState.gun_enabled:
#		queue_free()

func tween_collect(percent: float, start_position: Vector2):
	if collector == null:
		queue_free()
		return
	global_position = start_position.lerp(collector.global_position, percent)
	var direction_from_start = collector.global_position - start_position
	
	var target_rotation = direction_from_start.angle() + deg_to_rad(90)
	rotation = lerp_angle(rotation, target_rotation, 1-exp(-2*get_process_delta_time()))

func collect():
	GameEvents.emit_gun_collected()
	collected.emit()
#	AudioManager.request_audio(sounds, global_position)
	queue_free()


func on_area_entered(other_area: Area2D):
	if is_collected: return
	is_collected = true	
	GameState.unlock_gun()
	SharedPlayerManager.register_pickup(self)
	collector = other_area.get_parent()
	tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), 0.0, 1.0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.05).set_delay(0.45)
	tween.chain()
	tween.tween_callback(collect)



