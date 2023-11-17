extends CanvasLayer

const SQUEEZE_TWEEN_TIME = 0.1
const FILL_TWEEN_TIME = 0.25
const PARTICLE_TWEEN_TIME = 0.2
const STANDARD_PARTICLES = 5
const MID_HEALTH = 2
const MID_PARTICLE_MULTIPLIER = 2
const LOW_HEALTH = 1
const LOW_PARTICLE_MULTIPLIER = 4

@export var water_manager: Node

var _tween
var _squeeze_tween
var _particle_tween

@onready var meter_container = %MeterContainer
@onready var water_drops: GPUParticles2D = %WaterDrops
@onready var fill_bar: TextureRect = %FillBar
@onready var squeezer: TextureRect = %Squeezer

func _ready() -> void:
	GameEvents.health_changed.connect(_update_particles)
	water_manager.water_changed.connect(_update_progress)


func _physics_process(_delta: float) -> void:	
	if water_manager.water_percent <= 0:
		water_drops.emitting = false
	else:
		water_drops.emitting = true
	if not GameState.state.abilities.jetpack:
		return
	if Input.is_action_just_pressed("jump"):
		_squeeze_bar(true)
	elif Input.is_action_just_released("jump"):
		_squeeze_bar(false)


func _squeeze_bar(should_squeeze: bool) -> void:
	_squeeze_tween = create_tween()
	_squeeze_tween.tween_property(squeezer, "material:shader_parameter/squeeze_amount", int(should_squeeze), SQUEEZE_TWEEN_TIME).from_current()


func _update_progress(value: float) -> void:
	_tween = create_tween()
	_tween.tween_property(fill_bar, "material:shader_parameter/progress", value, FILL_TWEEN_TIME)


func _update_particles(health: int) -> void:
	var amount = STANDARD_PARTICLES
	if health == MID_HEALTH:
		amount = STANDARD_PARTICLES * MID_PARTICLE_MULTIPLIER
	if health == LOW_HEALTH:
		amount = STANDARD_PARTICLES * LOW_PARTICLE_MULTIPLIER
	_particle_tween = create_tween()
	_particle_tween.tween_property(water_drops, "amount", amount, PARTICLE_TWEEN_TIME).from_current()

