extends Toggleable
class_name SpikeTrap

signal finished_charging
signal finished_discharging

const FULL_FRAME_PROGRESS := 1.0
const LIGHT_FADE_TIME := 1.0
const CHARGE_UP_ANIMATION := "activate"
const ACTIVE_ANIMATION := "activeloop"
const DEACTIVATE_ANIMATION := "deactivate"
const SPIKE_CHARGE_TIME := 0.8
const SPIKE_DISCHARGE_TIME := 0.8
const FIRE_LOOP_SOUND_DB := -4.052

@export var always_on := true
@export var sound_enabled := false
@export var off_time: float = 5
@export var on_time: float = 2
@export var initial_delay: float = 0.5

var _looping := false
var _deactivated_frame := 7
var _current_state = TrapCoordinator.TrapState.INACTIVE

@onready var damaging_zone: Area2D = $DamagingZone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var charge_sound: AudioStreamPlayer2D = %ChargeSound
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var loop_sound: AudioStreamPlayer2D = %LoopSound
@onready var discharge_sound: AudioStreamPlayer2D = %DischargeSound 
@onready var light: PointLight2D = %Light

func _ready() -> void:
	animated_sprite_2d.set_frame_and_progress(_deactivated_frame, FULL_FRAME_PROGRESS)
	super()
	
	if always_on:
		# Always-on spikes bypass the coordinator system
		if not power_controller.powered:
			deactivate(true)
		else:
			activate(true)
	else:
		# Register with coordinator for synchronized timing
		TrapCoordinator.register_trap(self, initial_delay, on_time, off_time, SPIKE_CHARGE_TIME, SPIKE_DISCHARGE_TIME)

# Called by TrapCoordinator for synchronized mode
func start_charging() -> void:
	if not power_controller.powered:
		return
		
	_current_state = TrapCoordinator.TrapState.CHARGING
	
	light.visible = true
	var light_tween := create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.FULL_OPACITY, LIGHT_FADE_TIME)
	
	if sound_enabled:
		charge_sound.play()
	
	animated_sprite_2d.play(CHARGE_UP_ANIMATION)

func start_active() -> void:
	if not power_controller.powered:
		return
		
	_current_state = TrapCoordinator.TrapState.ACTIVE
	
	light.visible = true
	light.color.a = g.FULL_OPACITY
	animated_sprite_2d.play(ACTIVE_ANIMATION)
	
	if sound_enabled:
		charge_sound.stop()
		fire_sound.play()
		loop_sound.play()
	
	damaging_zone.set_deferred(MONITORING, true)
	_looping = true
	activated.emit()

func start_discharging() -> void:
	_current_state = TrapCoordinator.TrapState.DISCHARGING
	
	animated_sprite_2d.play(DEACTIVATE_ANIMATION)
	var light_tween := create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.NO_OPACITY, LIGHT_FADE_TIME)
	
	if sound_enabled:
		loop_sound.stop()
		discharge_sound.play()
		fire_sound.stop()
		## Stop fire sound after a brief delay
		#get_tree().create_timer(0.25, false, true).timeout.connect(func():
			#fire_sound.stop()
		#, CONNECT_ONE_SHOT)
	
	damaging_zone.set_deferred(MONITORING, false)
	_looping = false

func start_inactive() -> void:
	_current_state = TrapCoordinator.TrapState.INACTIVE
	
	animated_sprite_2d.set_frame_and_progress(_deactivated_frame, FULL_FRAME_PROGRESS)
	light.visible = false
	damaging_zone.set_deferred(MONITORING, false)
	_looping = false
	
	if sound_enabled:
		loop_sound.stop()
		fire_sound.stop()
	
	if power_controller.powered:
		deactivated.emit()

# Called during player reset for graceful audio shutdown
func force_reset() -> void:
	_graceful_sound_shutdown()
	_current_state = TrapCoordinator.TrapState.INACTIVE
	start_inactive()

func _graceful_sound_shutdown() -> void:
	if not sound_enabled:
		return
		
	# Fade out all current sounds over 1 second
	var fade_tween := create_tween()
	fade_tween.set_parallel()
	
	if charge_sound.playing:
		fade_tween.tween_property(charge_sound, g.DB_PROPERTY, g.SILENT_DB, 1.0)
	if fire_sound.playing:
		fade_tween.tween_property(fire_sound, g.DB_PROPERTY, g.SILENT_DB, 1.0)
	if loop_sound.playing:
		fade_tween.tween_property(loop_sound, g.DB_PROPERTY, g.SILENT_DB, 1.0)
	
	# Play discharge sound if not already playing
	if not discharge_sound.playing:
		discharge_sound.play()
	
	# After fade, stop all sounds and reset volumes
	fade_tween.tween_callback(_cleanup_after_fade).set_delay(1.0)

func _cleanup_after_fade() -> void:
	charge_sound.stop()
	fire_sound.stop()
	loop_sound.stop()
	
	# Reset volumes for next use
	charge_sound.volume_db = g.NORMAL_DB
	fire_sound.volume_db = FIRE_LOOP_SOUND_DB
	loop_sound.volume_db = FIRE_LOOP_SOUND_DB
	discharge_sound.volume_db = g.NORMAL_DB

# Always-on spike methods (bypass coordinator system)
func activate(instant: bool = false) -> void:
	light.visible = true
	light.color.a = g.FULL_OPACITY
	animated_sprite_2d.play(ACTIVE_ANIMATION)
	
	if instant and sound_enabled:
		loop_sound.play()
	
	damaging_zone.set_deferred(MONITORING, true)
	_looping = true
	activated.emit()

func deactivate(instant: bool = false) -> void:
	var light_tween := create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.NO_OPACITY, g.INSTANT_TIME if instant else LIGHT_FADE_TIME)
	animated_sprite_2d.play(DEACTIVATE_ANIMATION)
	
	if instant:
		animated_sprite_2d.set_frame_and_progress(_deactivated_frame, FULL_FRAME_PROGRESS)
	
	damaging_zone.set_deferred(MONITORING, false)
	_looping = false
	
	if sound_enabled:
		loop_sound.stop()
		fire_sound.stop()
	
	if power_controller.powered:
		deactivated.emit()

func make_invisible(instant: bool = false) -> void:
	var tween_time := g.INSTANT_TIME if instant else FADE_TIME
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, g.DB_PROPERTY, g.SILENT_DB, tween_time).from_current()
	tween.tween_property(charge_sound, g.DB_PROPERTY, g.SILENT_DB, tween_time).from_current()
	tween.tween_property(fire_sound, g.DB_PROPERTY, g.SILENT_DB, tween_time).from_current()
	tween.tween_property(discharge_sound, g.DB_PROPERTY, g.SILENT_DB, tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, tween_time).from_current()
	await tween.finished
	made_invisible.emit()

func make_visible(instant: bool = false) -> void:
	var tween_time := g.INSTANT_TIME if instant else FADE_TIME
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.FULL_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, g.DB_PROPERTY, FIRE_LOOP_SOUND_DB, tween_time).from_current()
	tween.tween_property(charge_sound, g.DB_PROPERTY, g.NORMAL_DB, tween_time).from_current()
	tween.tween_property(fire_sound, g.DB_PROPERTY, FIRE_LOOP_SOUND_DB, tween_time).from_current()
	tween.tween_property(discharge_sound, g.DB_PROPERTY, g.NORMAL_DB, tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, tween_time).from_current()
	await tween.finished
	made_visible.emit()

func on_power_changed(powered: bool) -> void:
	if powered:
		if always_on:
			activate()
		# Synced spikes will automatically resume when coordinator checks power_controller.powered
	else:
		# Immediately deactivate when power is lost, regardless of type
		if always_on:
			deactivate()
		else:
			force_reset()  # Gracefully shut down synced spikes
