class_name WaterMeter
extends CanvasLayer

const SQUEEZE_TWEEN_TIME := 0.1
const FILL_TWEEN_TIME := 0.25
const PARTICLE_TWEEN_TIME := 0.2
const STANDARD_PARTICLES := 5
const MID_HEALTH := 2
const MID_PARTICLE_MULTIPLIER := 2
const LOW_HEALTH := 1
const LOW_PARTICLE_MULTIPLIER := 4
const SQUEEZE_PARAMETER := "material:shader_parameter/squeeze_amount"
const PROGRESS_PARAMETER := "material:shader_parameter/progress"

@export var water_manager: Node

var _tween: Tween
var _squeeze_tween: Tween
var _particle_tween: Tween

@onready var _water_drops: GPUParticles2D = %WaterDrops
@onready var _fill_bar: TextureRect = %FillBar
@onready var _squeezer: TextureRect = %Squeezer
@onready var _vision_controller: MarginContainer = $VisionController

func _ready() -> void:
	GameEvents.health_changed.connect(_update_particles)
	water_manager.water_changed.connect(_update_progress)


func _physics_process(_delta: float) -> void:	
	if water_manager.water_percent <= 0:
		_water_drops.emitting = false
	else:
		_water_drops.emitting = true
	if not GameState.state.abilities.jetpack:
		return
	if Input.is_action_just_pressed(g.JETPACK_BUTTON):
		_squeeze_bar(true)
	elif Input.is_action_just_released(g.JETPACK_BUTTON):
		_squeeze_bar(false)


func _squeeze_bar(should_squeeze: bool) -> void:
	_squeeze_tween = create_tween()
	_squeeze_tween.tween_property(_squeezer, SQUEEZE_PARAMETER, int(should_squeeze), SQUEEZE_TWEEN_TIME).from_current()


func _update_progress() -> void:
	_tween = create_tween()
	_tween.tween_property(_fill_bar, PROGRESS_PARAMETER, SharedPlayerManager.request_water_percentage(), FILL_TWEEN_TIME)


func _update_particles(health: int) -> void:
	var particle_amount = STANDARD_PARTICLES
	if health == MID_HEALTH:
		particle_amount = STANDARD_PARTICLES * MID_PARTICLE_MULTIPLIER
	if health == LOW_HEALTH:
		particle_amount = STANDARD_PARTICLES * LOW_PARTICLE_MULTIPLIER
	_particle_tween = create_tween()
	_particle_tween.tween_property(_water_drops, g.PARTICLE_AMOUNT, particle_amount, PARTICLE_TWEEN_TIME).from_current()


func fade_visibility(vis: bool, fade_time: float) -> void:
	var tween = create_tween()	
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	if vis == false:
		_water_drops.emitting = false
		tween.tween_property(_vision_controller, g.OPACITY, g.NO_OPACITY, fade_time).from(g.FULL)
	else:
		_water_drops.emitting = true
		tween.tween_property(_vision_controller, g.OPACITY, g.FULL_OPACITY, fade_time).from(g.EMPTY)	
