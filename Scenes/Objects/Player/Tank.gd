class_name Tank
extends RigidBody2D

signal tank_hurt

const INVINCIBILITY_TIME := 1.0
const ON_HIT_WATER_LOSS := 0.1
const ON_HIT_WATER_LOSS_DEVIATION := 0.015

const DIALOGUE_LINEAR_DAMP := 30.0
const DIALOGUE_ANGULAR_DAMP := 30.0

const NORMAL_LINEAR_DAMP := 0.0
const NORMAL_ANGULAR_DAMP := 3.0

const TANK_IMPULSE_MULTIPLIER := 0.75
const STANDARD_SCREENSHAKE_NUMBER := 0.5

var _damageable := true

@onready var ping_animation: Node2D = $PingAnimation
@onready var magnet_module: MagnetModule = $MagnetModule

@onready var _water_drops: GPUParticles2D = %WaterDrops
@onready var _shield_module: ShieldModule = $ShieldModule

func _ready() -> void:
	SharedPlayerManager.tank = self
	GameEvents.dialogue_started.connect(_on_dialogue_started)
	GameEvents.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started() -> void:
	linear_damp = DIALOGUE_LINEAR_DAMP
	angular_damp = DIALOGUE_ANGULAR_DAMP


func _on_dialogue_ended() -> void:
	linear_damp = DIALOGUE_LINEAR_DAMP
	angular_damp = DIALOGUE_ANGULAR_DAMP


func player_take_damage(impulse: Vector2) -> void:
	if not _damageable:
		return
	
	tank_hurt.emit()
	GlobalCamera.add_trauma(STANDARD_SCREENSHAKE_NUMBER)
	_damageable = false
	
	SharedPlayerManager.request_pause_frames()
	linear_velocity = Vector2.ZERO
	if _shield_module.shielded:
		_shield_module.remove_shield()
	else:
		apply_central_impulse(impulse)
		_water_drops.emitting = true
		GameEvents.emit_water_collected(-randfn(ON_HIT_WATER_LOSS, ON_HIT_WATER_LOSS_DEVIATION))
	
	_invincibility_frames()


func _invincibility_frames() -> void:
	_damageable = false
	await get_tree().create_timer(INVINCIBILITY_TIME, false, true).timeout
	_damageable = true
