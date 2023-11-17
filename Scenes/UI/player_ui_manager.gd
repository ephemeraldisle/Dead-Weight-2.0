extends CanvasLayer
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


func enable_battery_ui() -> void:
	battery_meter.visible = true


func enable_water_ui() -> void:
	water_meter.visible = true


func enable_health_ui() -> void:
	ekg.visible = true
	ekg.can_beep = true
	ekg._on_beep_toggled()
