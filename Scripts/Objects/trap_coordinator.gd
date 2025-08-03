extends Node

const TICK_INTERVAL := 0.05
enum TrapState {
	INACTIVE,
	CHARGING,
	ACTIVE,
	DISCHARGING
}

var _trap_list := {}
var _last_tick := 0.0

func _ready() -> void:
	TimeController.timer_ticked.connect(_on_timer_tick)
	SharedPlayerManager.player_spawned.connect(_on_player_reset)

func register_trap(trap, initial_delay: float, on_time: float, off_time: float, charge_time: float, discharge_time: float) -> void:
	var cycle_time := on_time + off_time + charge_time + discharge_time
	_trap_list[trap] = {
		"initial_delay": initial_delay,
		"on_time": on_time,
		"off_time": off_time,
		"charge_time": charge_time,
		"discharge_time": discharge_time,
		"cycle_time": cycle_time,
		"state": TrapState.INACTIVE,
		"state_start_time": 0.0
	}

func _on_timer_tick(time: float) -> void:
	if time < _last_tick:
		_last_tick = time
	
	if time - _last_tick >= TICK_INTERVAL:
		_update_traps(time)
		_last_tick = time

func _update_traps(time: float) -> void:
	for trap in _trap_list:
		var data = _trap_list[trap]
		
		# Skip unpowered or always-on traps
		if not trap.power_controller.powered or trap.always_on:
			if data.state != TrapState.INACTIVE:
				data.state = TrapState.INACTIVE
				trap.force_reset()
			continue
			
		var cycle_start_time = data.initial_delay
		var current_cycle_time := fmod(time - cycle_start_time, data.cycle_time)
		
		if time < cycle_start_time:
			continue
			
		var new_state := _calculate_state(current_cycle_time, data)
		
		if new_state != data.state:
			_transition_state(trap, data, new_state, time)

func _calculate_state(cycle_time: float, data: Dictionary) -> TrapState:
	var charge_time: float = data.charge_time
	var discharge_time: float = data.discharge_time
	
	if cycle_time < charge_time:
		return TrapState.CHARGING
	elif cycle_time < charge_time + data.on_time:
		return TrapState.ACTIVE
	elif cycle_time < charge_time + data.on_time + discharge_time:
		return TrapState.DISCHARGING
	else:
		return TrapState.INACTIVE

func _transition_state(trap, data: Dictionary, new_state: TrapState, time: float) -> void:
	data.state = new_state
	data.state_start_time = time
	
	match new_state:
		TrapState.CHARGING:
			trap.start_charging()
		TrapState.ACTIVE:
			trap.start_active()
		TrapState.DISCHARGING:
			trap.start_discharging()
		TrapState.INACTIVE:
			trap.start_inactive()

func _on_player_reset() -> void:
	for trap in _trap_list:
		var data = _trap_list[trap]
		data.state = TrapState.INACTIVE
		data.state_start_time = 0.0
		trap.force_reset()
