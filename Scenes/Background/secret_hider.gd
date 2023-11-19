extends Area2D

@export var things_to_hide: Array[Node2D]
@export var things_to_deactivate: Array[Node2D]
var occupied = false

func _ready() -> void:
	GameEvents.player_died.connect(reset)
	for thing in things_to_hide:
		thing.visible = false

func reset() -> void:
	no_show()

func _on_body_entered(body: Node2D) -> void:
	if occupied: return
	var tween = create_tween()
	for thing in things_to_hide:
		thing.visible = true
	tween.tween_property(self, "modulate:a", 0, 0.25)
	await tween.finished
	for thing in things_to_hide:
		if thing.has_method("appear"):
			thing.appear()
	for thing in things_to_deactivate:
		if thing.has_method("activate"):
			thing.activate()
	visible = false
	occupied = true



func _on_body_exited(body: Node2D) -> void:
	if get_overlapping_bodies().size() > 0:
		return
	no_show()
	

func deactivate(some_bool: bool = false) -> void:
	_on_body_entered(self)

func reactivate() -> void:
	no_show()



func no_show() -> void:
	var tween = create_tween()
	visible = true
	tween.tween_property(self, "modulate:a", 1, 0.25)
	for thing in things_to_hide:
		if thing.has_method("vanish"):
			thing.vanish()
	for thing in things_to_deactivate:
		if thing.has_method("deactivate"):
			thing.deactivate()
	await tween.finished
	for thing in things_to_hide:
		thing.visible = false
	occupied = false
