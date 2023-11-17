extends RigidBody2D
@onready var animation_player = $AnimationPlayer

var ping_animation = null

func _ready():
	if get_child_count(false) > 3:
		ping_animation = $PingAnimation

func start_animation():
	animation_player.play("pump")
