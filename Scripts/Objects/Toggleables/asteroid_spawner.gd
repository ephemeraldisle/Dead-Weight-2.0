extends Toggleable
class_name AsteroidSpawner

@export var asteroid_scene: PackedScene
@export var spawn_interval: float = 2.0  # Time between spawns in seconds
@export var spawn_radius: float = 100.0  # Default radius if no specific area is set

var _spawn_shape: CollisionShape2D

@onready var _spawn_timer: Timer = $TimerComponent

func _ready() -> void:
	super()
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(_spawn_timer)

	# Look for a local CollisionShape2D
	_spawn_shape = get_node_or_null("CollisionShape2D")

func activate(_instant: bool = false) -> void:
	super(_instant)
	_spawn_timer.start()

func deactivate(_instant: bool = false) -> void:
	super(_instant)
	_spawn_timer.stop()

func _on_spawn_timer_timeout() -> void:
	if power_controller.powered:
		_spawn_asteroid()

func _spawn_asteroid() -> void:
	if not asteroid_scene:
		return

	var new_asteroid = asteroid_scene.instantiate()
	var spawn_position: Vector2

	if _spawn_shape and _spawn_shape.shape is CircleShape2D:
		var circle_shape = _spawn_shape.shape as CircleShape2D
		var random_angle = randf() * TAU
		var random_radius = sqrt(randf()) * circle_shape.radius
		spawn_position = Vector2(cos(random_angle), sin(random_angle)) * random_radius
	elif _spawn_shape and _spawn_shape.shape is RectangleShape2D:
		var rect_shape = _spawn_shape.shape as RectangleShape2D
		spawn_position = Vector2(
			randf_range(-rect_shape.extents.x, rect_shape.extents.x),
			randf_range(-rect_shape.extents.y, rect_shape.extents.y)
		)
	else:
		# Fallback to circular spawn if no specific shape is set
		var random_angle = randf() * TAU
		var random_radius = sqrt(randf()) * spawn_radius
		spawn_position = Vector2(cos(random_angle), sin(random_angle)) * random_radius

	new_asteroid.global_position = global_position + spawn_position
	get_tree().current_scene.add_child(new_asteroid)

func on_power_changed(powered: bool) -> void:
	if powered:
		activate()
	else:
		deactivate()
