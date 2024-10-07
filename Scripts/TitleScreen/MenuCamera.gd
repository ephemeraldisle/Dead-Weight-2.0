extends Camera2D

const DIRECTION = Vector2.UP*5

var _original_position
var _distance

@onready var intro_screen = $".."

func _ready() -> void:
	GlobalCamera.follow_node(self)
	_original_position = global_position
	
func do_shake() -> void:
	GlobalCamera.add_trauma(1)

func _process(delta) -> void:
	global_position += DIRECTION
	_distance = global_position.y - _original_position.y
	intro_screen.offset.y = _distance
