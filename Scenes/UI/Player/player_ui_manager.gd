extends CanvasLayer

const FADE_TIME = 0.4

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

func toggle_all(vis: bool, instant = false) -> void:
	toggle_battery_ui(vis, instant)
	toggle_water_ui(vis, instant)
	toggle_health_ui(vis, instant)	


func toggle_battery_ui(vis: bool, instant = false) -> void:
	if instant:
		battery_meter.visible = vis
	else:
		battery_meter.fade_visibility(vis, FADE_TIME)


func toggle_water_ui(vis: bool, instant = false) -> void:
	if instant:
		water_meter.visible = vis
	else:
		water_meter.fade_visibility(vis, FADE_TIME)


func toggle_health_ui(vis: bool, instant = false) -> void:
	if instant:
		ekg.visible = vis
	else:
		ekg.fade_visibility(vis, FADE_TIME)
		ekg.can_beep = vis
		ekg._on_beep_toggled()
