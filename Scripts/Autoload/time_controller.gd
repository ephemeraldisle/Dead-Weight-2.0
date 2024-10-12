extends Node

signal timer_ticked(number: float)

const TICK_INTERVAL: float = 0.05

var _time_passed := 0.0
var _last_tick := 0.0

func _ready() -> void:
	SharedPlayerManager.player_spawned.connect(_on_player_spawned)


func _process(delta: float) -> void:
	_time_passed += delta
	if _time_passed - _last_tick >= TICK_INTERVAL:
		timer_ticked.emit(_time_passed)
		_last_tick =_time_passed
	

func _on_player_spawned() -> void:
	_time_passed = 0
	_last_tick = 0
	
