extends CanvasLayer

enum Health {
	_NO_HEALTH,
	CRISIS_HEALTH,
	WARNING_HEALTH,
	MAX_HEALTH,
}

const STYLE_SETTINGS = {
	Health.MAX_HEALTH: {
		COLOR = Color("54de60"),
		CONDITION_TEXT = "Condition: Stable",
		ANIMATION_SPEED_SCALE = 1,
		BEEP_PITCH = 0.9,
	},
	Health.WARNING_HEALTH: {
		COLOR = Color("ffef08"),
		CONDITION_TEXT = "Condition: Serious",
		ANIMATION_SPEED_SCALE = 2.5,
		BEEP_PITCH = 1.05,
	},
	Health.CRISIS_HEALTH: {
		COLOR = Color("ff0015"),
		CONDITION_TEXT = "Condition: CRITICAL!",
		ANIMATION_SPEED_SCALE = 5,
		BEEP_PITCH = 1.3,
	},
	}

const SILENT_DB = -80

var can_beep = false

@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var ekg_line = %EkgLine
@onready var event_player = $EventPlayer
@onready var condition_label = %ConditionLabel as Label
@onready var beep_sound: AudioStreamPlayer = $BeepSound
@onready var hearts: GPUParticles2D = $Hearts


func _ready() -> void:
	GameEvents.beep_toggled.connect(_on_beep_toggled)
	_on_beep_toggled()
	GameEvents.health_changed.connect(set_status)

func _on_beep_toggled() -> void:
	if not can_beep:
		return
	beep_sound.volume_db = 0 if GameState.options.heart_beep else SILENT_DB


func set_status(health):
	if health == 0 or health > Health.MAX_HEALTH:
		return
	ekg_line.modulate = STYLE_SETTINGS[health].COLOR
	condition_label.label_settings.font_color = STYLE_SETTINGS[health].COLOR
	condition_label.text = STYLE_SETTINGS[health].CONDITION_TEXT
	animation_player.speed_scale = STYLE_SETTINGS[health].ANIMATION_SPEED_SCALE
	event_player.speed_scale = STYLE_SETTINGS[health].ANIMATION_SPEED_SCALE
	beep_sound.pitch_scale =STYLE_SETTINGS[health].BEEP_PITCH
	
	if health != Health.MAX_HEALTH:
		hearts.emitting = SharedPlayerManager.request_water_percentage() > 0
	else:
		hearts.emitting = false
