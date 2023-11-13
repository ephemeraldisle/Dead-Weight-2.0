extends RigidBody2D

signal tank_hurt

const INVINCIBILITY_TIME = 1
const ON_HIT_WATER_LOSS = 0.1
const ON_HIT_WATER_LOSS_DEVIATION = 0.015

var _damageable = true

@onready var ping_animation = $PingAnimation
@onready var action_finder = $ActionFinder
@onready var water_drops: GPUParticles2D = %WaterDrops
@onready var magnet_module: Node2D = $MagnetModule
@onready var shield_module: Node2D = $ShieldModule


func _ready() -> void:
	SharedPlayerManager.tank = self
	GameEvents.dialogue_started.connect(on_dialogue_started)
	GameEvents.dialogue_ended.connect(on_dialogue_ended)


func on_dialogue_started() -> void:
	linear_damp = 30
	angular_damp = 30


func on_dialogue_ended() -> void:
	linear_damp = 0
	angular_damp = 3


func player_take_damage(impulse: Vector2) -> void:
	if not _damageable:
		return
	
	tank_hurt.emit()
	GlobalCamera.add_trauma(0.5)
	_damageable = false
	
	SharedPlayerManager.request_pauseframes()
	
	if shield_module.shielded:
		shield_module.remove_shield()
	else:
		apply_central_impulse(impulse * 0.5)
		water_drops.emitting = true
		GameEvents.emit_water_collected(-randfn(ON_HIT_WATER_LOSS, ON_HIT_WATER_LOSS_DEVIATION))
	
	invicibilty_frames()


func invicibilty_frames() -> void:
	_damageable = false
	await get_tree().create_timer(INVINCIBILITY_TIME, false, true).timeout
	_damageable = true
