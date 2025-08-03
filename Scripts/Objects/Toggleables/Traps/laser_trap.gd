extends Toggleable
class_name LaserTrap

signal finished_charging
signal finished_discharging

const SOUND_FADE_TIME := FADE_TIME * 2.0
const LIGHT_CHARGE_TIME := 1
const CHARGING_ANIMATION := "Activate"
const CHARGE_SOUND_TIME := 1.15
const LOOPING_SOUND_TIME := 3
const DISCHARGE_SOUND_TIME := 0.25
const FIRE_LOOP_SOUND_DB := -4.052

const CHARGE_TIME := 1.166667
const DISCHARGE_TIME := 1.133333

@export var always_on := false
@export var sound_enabled := false
@export var off_time: float = 5
@export var on_time: float = 2
@export var initial_delay: float = 0.5
@export var debug := false

var _active_animation := "Active"
var _deactivate_animation := "Deactivate"
var _off_animation := "Inactive"
var _current_state = TrapCoordinator.TrapState.INACTIVE

@onready var damaging_zone: Area2D = $DamagingZone
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var charge_sound: AudioStreamPlayer2D = %ChargeSound
@onready var fire_sound: AudioStreamPlayer2D = %FireSound
@onready var loop_sound: AudioStreamPlayer2D = %LoopSound
@onready var discharge_sound: AudioStreamPlayer2D = %DischargeSound
@onready var light: PointLight2D = %Light
@onready var wall: StaticBody2D = %Wall

func _ready() -> void:
	super()
	
	if always_on:
		# Always-on lasers bypass the master system
		if not power_controller.powered:
			deactivate(true)
		else:
			activate(true)
	else:
		# Register with the master for synchronized timing
		TrapCoordinator.register_trap(self, initial_delay, on_time, off_time, CHARGE_TIME, DISCHARGE_TIME)

# Called by TrapCoordinator for synchronized mode
func start_charging() -> void:
	if not power_controller.powered:
		return
		
	_current_state = TrapCoordinator.TrapState.CHARGING
	
	light.visible = true
	var light_tween := create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.FULL_OPACITY, LIGHT_CHARGE_TIME)
	
	if sound_enabled:
		charge_sound.play()
	
	animated_sprite_2d.play(CHARGING_ANIMATION)

func start_active() -> void:
	if not power_controller.powered:
		return
		
	_current_state = TrapCoordinator.TrapState.ACTIVE
	
	animated_sprite_2d.play(_active_animation)
	if sound_enabled:
		charge_sound.stop()
		fire_sound.play()
		# Start loop sound if on_time is long enough
		if on_time > LOOPING_SOUND_TIME:
			var loop_delay := LOOPING_SOUND_TIME
			get_tree().create_timer(loop_delay, false, true).timeout.connect(func(): 
				if _current_state == TrapCoordinator.TrapState.ACTIVE and sound_enabled: 
					loop_sound.play()
			, CONNECT_ONE_SHOT)
	
	damaging_zone.monitoring = true
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, true)
	activated.emit()

func start_discharging() -> void:
	_current_state = TrapCoordinator.TrapState.DISCHARGING 
	
	animated_sprite_2d.play(_deactivate_animation)
	var light_tween := create_tween() as Tween
	light_tween.tween_property(light, g.LIGHT_OPACITY, g.NO_OPACITY, LIGHT_CHARGE_TIME)
	
	if sound_enabled:
		loop_sound.stop()
		discharge_sound.play()
		# Stop fire sound after discharge finishes  
		get_tree().create_timer(DISCHARGE_SOUND_TIME, false, true).timeout.connect(func():
			fire_sound.stop()
		, CONNECT_ONE_SHOT)
	
	damaging_zone.set_deferred(MONITORING, false)
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)

func start_inactive() -> void:
	_current_state = TrapCoordinator.TrapState.INACTIVE
	
	animated_sprite_2d.play(_off_animation)
	light.visible = false
	damaging_zone.set_deferred(MONITORING, false)
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)
	
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

# Always-on laser methods (bypass master system)
func activate(instant: bool = false) -> void:
	light.visible = true
	light.color.a = g.FULL_OPACITY
	animated_sprite_2d.play(_active_animation)

	if instant and sound_enabled:
		loop_sound.play()

	damaging_zone.monitoring = true
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, true)
	activated.emit()

func deactivate(instant: bool = false) -> void:
	animated_sprite_2d.play(_off_animation)
	light.visible = false
	damaging_zone.set_deferred(MONITORING, false)
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)
	
	if sound_enabled:
		loop_sound.stop()
		fire_sound.stop()
	
	if power_controller.powered:
		deactivated.emit()

func make_invisible(instant: bool = false) -> void:
	var tween_time := g.INSTANT_TIME if instant else FADE_TIME
	var sound_tween_time := g.INSTANT_TIME if instant else SOUND_FADE_TIME
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.NO_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(charge_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(fire_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(discharge_sound, g.DB_PROPERTY, g.SILENT_DB, sound_tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.NO_OPACITY, tween_time).from_current()
	await tween.finished
	made_invisible.emit()

func make_visible(instant: bool = false) -> void:
	var tween_time := g.INSTANT_TIME if instant else FADE_TIME
	var sound_tween_time := g.INSTANT_TIME if instant else SOUND_FADE_TIME
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(light, g.LIGHT_POWER, g.FULL_LIGHT_POWER, tween_time).from_current()
	tween.tween_property(loop_sound, g.DB_PROPERTY, FIRE_LOOP_SOUND_DB, sound_tween_time).from_current()
	tween.tween_property(charge_sound, g.DB_PROPERTY, g.NORMAL_DB, sound_tween_time).from_current()
	tween.tween_property(fire_sound, g.DB_PROPERTY, FIRE_LOOP_SOUND_DB, sound_tween_time).from_current()
	tween.tween_property(discharge_sound, g.DB_PROPERTY, g.NORMAL_DB, sound_tween_time).from_current()
	tween.tween_property(self, g.OPACITY, g.FULL_OPACITY, tween_time).from_current()
	await tween.finished
	made_visible.emit()

func on_power_changed(powered: bool) -> void:
	if powered:
		if always_on:
			activate()
		# Synced lasers will automatically resume when master checks power_controller.powered
	else:
		# Immediately deactivate when power is lost, regardless of type
		if always_on:
			deactivate()
		else:
			force_reset()  # Gracefully shut down synced lasers
