extends Node2D
class_name Pickup

signal collected

const TWEEN_DURATION := 0.5
const SCALE_DURATION := 0.05
const SCALE_DELAY := 0.45
const ROTATION_OFFSET := PI / 2
const ROTATION_LERP_FACTOR := 2.0
const VOLUME_DB := 15.0
const FROM_ORIGIN := 0.0
const TO_COLLECTOR := 1.0

@onready var area_2d := $Area2D

var sprite: Node2D
var is_collected := false
var collector: Node2D
var tween: Tween

@export var pickup_sound: AudioStream

func _ready() -> void:
	area_2d.area_entered.connect(on_area_entered)
	setup_sprite()

func setup_sprite() -> void:
	push_error("setup_sprite() must be implemented in derived classes")

func tween_collect(percent: float, start_position: Vector2) -> void:
	if collector == null:
		collected.emit()
		queue_free()
		return
	
	global_position = start_position.lerp(collector.global_position, percent)
	var direction_from_start := collector.global_position - start_position
	
	var target_rotation := direction_from_start.angle() + ROTATION_OFFSET
	rotation = lerp_angle(rotation, target_rotation, 1.0 - exp(-ROTATION_LERP_FACTOR * get_process_delta_time()))

func collect() -> void:
	AudioManager.play_generic(pickup_sound, global_position, VOLUME_DB)
	collected.emit()
	queue_free()

func on_area_entered(other_area: Area2D) -> void:
	if is_collected:
		return
	
	is_collected = true	
	SharedPlayerManager.register_pickup(self)
	collector = other_area.get_parent()
	
	tween = create_tween()
	tween.set_parallel()
	tween.tween_method(tween_collect.bind(global_position), FROM_ORIGIN, TO_COLLECTOR, TWEEN_DURATION).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_property(sprite, g.SCALE, Vector2.ZERO, SCALE_DURATION).set_delay(SCALE_DELAY)
	tween.chain()
	tween.tween_callback(collect)
