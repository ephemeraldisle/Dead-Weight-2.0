extends Timer

@onready var parent = get_parent() as Toggleable
@onready var _off_time = parent.off_time

func _ready() -> void:
	if _off_time > 0:
		parent.deactivated.connect(begin_timer)

func begin_timer() -> void:
	if is_inside_tree():
		start(_off_time)

func change_time(time: float) -> void:
	if not is_stopped():
		var time_difference = _off_time - time
		var new_time = max(time_left - time_difference, 0)
		start(new_time)
	_off_time = time
