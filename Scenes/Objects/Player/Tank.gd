extends RigidBody2D

signal tank_hurt

const INVINCIBILITY_TIME = 1
const ON_HIT_WATER_LOSS = 0.1
const ON_HIT_WATER_LOSS_DEVIATION = 0.015

const DIALOGUE_LINEAR_DAMP = 30
const DIALOGUE_ANGULAR_DAMP = 30

const NORMAL_LINEAR_DAMP = 0
const NORMAL_ANGULAR_DAMP = 3

const TANK_IMPULSE_MULTIPLIER = 0.5
const STANDARD_SCREENSHAKE_NUMBER = 0.5

var _damageable = true

@onready var ping_animation = $PingAnimation
@onready var water_drops: GPUParticles2D = %WaterDrops
@onready var shield_module: Node2D = $ShieldModule
@onready var magnet_module: Node2D = $MagnetModule
@onready var action_finder: Area2D = $ActionFinder


func _ready() -> void:
	SharedPlayerManager.tank = self
	GameEvents.dialogue_started.connect(on_dialogue_started)
	GameEvents.dialogue_ended.connect(on_dialogue_ended)


func on_dialogue_started() -> void:
	linear_damp = DIALOGUE_LINEAR_DAMP
	angular_damp = DIALOGUE_ANGULAR_DAMP


func on_dialogue_ended() -> void:
	linear_damp = DIALOGUE_LINEAR_DAMP
	angular_damp = DIALOGUE_ANGULAR_DAMP


func player_take_damage(impulse: Vector2) -> void:
	if not _damageable:
		return
	
	tank_hurt.emit()
	GlobalCamera.add_trauma(STANDARD_SCREENSHAKE_NUMBER)
	_damageable = false
	
	SharedPlayerManager.request_pause_frames()
	
	if shield_module.shielded:
		shield_module.remove_shield()
	else:
		apply_central_impulse(impulse * TANK_IMPULSE_MULTIPLIER)
		water_drops.emitting = true
		GameEvents.emit_water_collected(-randfn(ON_HIT_WATER_LOSS, ON_HIT_WATER_LOSS_DEVIATION))
	
	invincibility_frames()


func invincibility_frames() -> void:
	_damageable = false
	await get_tree().create_timer(INVINCIBILITY_TIME, false, true).timeout
	_damageable = true
