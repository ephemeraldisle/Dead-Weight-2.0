extends CanvasLayer

const FADE_TIME = 0.5

@onready var energy_manager: Node2D = %EnergyManager

@onready var water_manager = %WaterManager
@onready var water_meter = $WaterMeter
@onready var ekg = $EKG
@onready var battery_meter = $BatteryMeter


#func _ready() -> void:
#	water_manager.water_changed.connect(on_water_changed)
#	on_water_changed()
#	energy_manager.energy_changed.connect(on_energy_changed)
#	on_energy_changed()
#
#
#func on_water_changed() -> void:
#	water_meter.update_progress(water_manager.water_percent)
#
#
#func on_energy_changed() -> void:
#	battery_meter.update_energy(
#		energy_manager.current_energy, energy_manager.max_energy, energy_manager.current_percent
#	)

func toggle_all(vis: bool) -> void:
	toggle_battery_ui(vis)
	toggle_water_ui(vis)
	toggle_health_ui(vis)	


func toggle_battery_ui(vis: bool) -> void:
	var tween = create_tween()
	tween.tween_property(battery_meter, "modulate:a", int(vis), FADE_TIME).from(int(not vis))
	battery_meter.visible = vis


func toggle_water_ui(vis: bool) -> void:
	var tween = create_tween()
	tween.tween_property(water_meter, "modulate:a", int(vis), FADE_TIME).from(int(not vis))
	water_meter.visible = vis


func toggle_health_ui(vis: bool) -> void:
	var tween = create_tween()
	tween.tween_property(ekg, "modulate:a", int(vis), FADE_TIME).from(int(not vis))
	ekg.visible = vis
	ekg.can_beep = vis
	ekg._on_beep_toggled()
