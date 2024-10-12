extends Node
class_name TurretMaster

const TURRET_INTERVAL := 0.5

var _turret_list = {}
var _last_tick := 0.0

func _ready() -> void:
	TimeController.timer_ticked.connect(_on_timer_tick)

func register_turret(turret: Turret, delay: float, cooldown: float) -> void:
	_turret_list[turret] = Vector2(delay, cooldown)
	
func _on_timer_tick(time: float) -> void:
	if time < _last_tick:
		_last_tick = time
	if time - _last_tick >= TURRET_INTERVAL:
		_activate_turrets(snapped(time, TURRET_INTERVAL))
		_last_tick = time

func _activate_turrets(time: float) -> void:
	for turret in _turret_list:
		if is_equal_approx(fmod(time, _turret_list[turret].y), _turret_list[turret].x):
			turret.fire_laser()
