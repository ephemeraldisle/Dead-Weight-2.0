extends CanvasLayer

@onready var battery_manager = %BatteryManager
@onready var health_manager = %HealthManager
@onready var water_manager = %WaterManager
@onready var water_meter = $WaterMeter
@onready var ekg = $EKG
@onready var battery_meter = $BatteryMeter


func _ready():
	water_manager.water_changed.connect(on_water_changed)
	on_water_changed()
	health_manager.health_changed.connect(on_health_changed)
	on_health_changed()
	battery_manager.energy_changed.connect(on_energy_changed)
	on_energy_changed()


func on_water_changed():
	water_meter.update_progress(water_manager.water_percent)


func on_health_changed():
	ekg.set_status(health_manager.health)


func on_energy_changed():
	battery_meter.update_energy(
		battery_manager.current_energy, battery_manager.max_energy, battery_manager.current_percent
	)


func enable_battery_ui():
	battery_meter.visible = true


func enable_water_ui():
	water_meter.visible = true


func enable_health_ui():
	ekg.visible = true
	ekg.can_beep = true
	ekg._on_beep_toggled()
