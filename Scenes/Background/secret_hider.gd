extends Area2D

const FADE_TIME := 0.25
const RECHECK_TIME := 0.5
const VISIBLE_METHOD := "make_visible"
const INVISIBLE_METHOD := "make_invisible"

@export var things_to_hide: Array[Node2D]

@onready var timer: Timer = $Timer

var _occupied := false
var _hiding := false

func _ready() -> void:
	timer.wait_time = RECHECK_TIME
	timer.timeout.connect(_on_timer_timeout)
	GameEvents.unsaved_reset.connect(hiding_routine)
	hiding_routine()

func show_things() -> void:
	for thing in things_to_hide:
		if thing.has_method(VISIBLE_METHOD):
			thing.call(VISIBLE_METHOD)
	for body in get_overlapping_bodies():
		if not body.visible:
			body.visible = true

func hide_things() -> void:
	for thing in things_to_hide:
		if thing.has_method(INVISIBLE_METHOD):
			thing.call(INVISIBLE_METHOD)

func showing_routine() -> void:
	var tween := create_tween()
	show_things()
	_occupied = true
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, FADE_TIME)
	await tween.finished
	visible = false

func hiding_routine() -> void:
	_hiding = true
	var tween := create_tween()
	hide_things()
	visible = true
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, FADE_TIME)
	await tween.finished
	_occupied = false
	_hiding = false

func _on_body_entered(body: CollisionObject2D) -> void:
	timer.start()
	if body.get_collision_layer_value(g.PLAYER_PROJECTILE_LAYER) and visible:
		body.visible = false
		return
	if _occupied:
		return
	showing_routine()

func _on_body_exited(body: Node2D) -> void:
	timer.start()
	if body.get_collision_layer_value(g.PLAYER_PROJECTILE_LAYER):
		body.visible = true
	if not get_overlapping_bodies().is_empty():
		return
	hiding_routine()

func _on_timer_timeout() -> void:
	if _hiding:
		return
	if get_overlapping_bodies().is_empty():
		hiding_routine()
		return
	if visible:
		for thing in get_overlapping_bodies():
			if not thing.get_collision_layer_value(g.PLAYER_PROJECTILE_LAYER):
				showing_routine()
				return


# func deactivate(some_bool: bool = false) -> void:
# 	_on_body_entered(self)

# func reactivate() -> void:
# 	hiding_routine()

# func reset() -> void:
# 	hiding_routine()
	

