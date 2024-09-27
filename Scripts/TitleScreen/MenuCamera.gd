extends Camera2D

var direction = Vector2.UP*5
var original_position
var distance
@onready var intro_screen = $".."

func _ready():
	GlobalCamera.follow_node(self)
	original_position = global_position
	
func do_shake():
	GlobalCamera.add_trauma(1)

func _process(delta):
	global_position += direction
	distance = global_position.y - original_position.y
	intro_screen.offset.y = distance
