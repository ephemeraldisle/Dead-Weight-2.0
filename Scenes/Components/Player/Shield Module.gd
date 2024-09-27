class_name ShieldModule
extends Node2D

const ENERGY_COST_PER_FRAME = 0.0055

@export var shield_animator: AnimationPlayer 
@export var shield_energy_cost := 0.75

var shielded = false
var _gathered_energy := 0.0

@onready var sparks: GPUParticles2D = %Sparks
@onready var shield_recharge: AudioStreamPlayer2D = %ShieldRecharge
@onready var shield_ready: AudioStreamPlayer2D = %ShieldReady
@onready var shield_burst: AudioStreamPlayer2D = %ShieldBurst
@onready var ability_power_controller: Node = $AbilityPowerController

func _ready() -> void:
	ability_power_controller.power_changed.connect(on_shield_enabled)
	if ability_power_controller.powered:
		start_shield()

func _physics_process(_delta: float) -> void:	
	if not ability_power_controller.powered:
		shielded = false
		return
	
	if not shielded:
		if SharedPlayerManager.request_energy_percentage() > 0:
			GameEvents.emit_energy_percent_changed(-ENERGY_COST_PER_FRAME)
			_gathered_energy += ENERGY_COST_PER_FRAME
		else:
			if not shield_recharge.playing:
				shield_recharge.play()
		
		if _gathered_energy >= shield_energy_cost:
			shield_recharge.stop()
			shield_ready.play()
			start_shield()

func remove_shield() -> void:
	shield_burst.play()
	shield_animator.play("shieldbreak")
	shielded = false
	sparks.emitting = true
	

func start_shield() -> void:
	shielded = true
	sparks.emitting = false
	shield_animator.play_backwards("shieldbreak")
	await shield_animator.animation_finished
	shield_animator.play("on")

func on_shield_enabled(enabled: bool) -> void:
	if enabled and not shielded:
		start_shield()
