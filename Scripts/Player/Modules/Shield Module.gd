class_name ShieldModule
extends Node2D

const ENERGY_COST_PER_FRAME := 0.0055
const SHIELD_BREAK_ANIMATION := "shieldbreak"
const SHIELD_ON_ANIMATION := "on"
const NO_ENERGY := 0.0

@export var shield_animator: AnimationPlayer 
@export var shield_energy_cost := 0.75

var shielded := false
var _gathered_energy := 0.0

@onready var sparks: GPUParticles2D = %Sparks
@onready var shield_recharge: AudioStreamPlayer2D = %ShieldRecharge
@onready var shield_ready: AudioStreamPlayer2D = %ShieldReady
@onready var shield_burst: AudioStreamPlayer2D = %ShieldBurst
@onready var ability_power_controller: AbilityPowerController = $AbilityPowerController

func _ready() -> void:
	ability_power_controller.power_changed.connect(_on_shield_enabled)
	if ability_power_controller.powered:
		start_shield()

func _physics_process(_delta: float) -> void:	
	if not ability_power_controller.powered:
		shielded = false
		return
	
	if not shielded:
		_handle_shield_recharge()

func _handle_shield_recharge() -> void:
	if SharedPlayerManager.request_energy_percentage() > NO_ENERGY:
		GameEvents.emit_energy_percent_changed(-ENERGY_COST_PER_FRAME)
		_gathered_energy += ENERGY_COST_PER_FRAME
	elif not shield_recharge.playing:
		shield_recharge.play()
	
	if _gathered_energy >= shield_energy_cost:
		_activate_shield()

func _activate_shield() -> void:
	shield_recharge.stop()
	shield_ready.play()
	start_shield()

func remove_shield() -> void:
	shield_burst.play()
	shield_animator.play(SHIELD_BREAK_ANIMATION)
	shielded = false
	sparks.emitting = true

func start_shield() -> void:
	shielded = true
	sparks.emitting = false
	shield_animator.play_backwards(SHIELD_BREAK_ANIMATION)
	await shield_animator.animation_finished
	shield_animator.play(SHIELD_ON_ANIMATION)

func _on_shield_enabled(enabled: bool) -> void:
	if enabled and not shielded:
		start_shield()