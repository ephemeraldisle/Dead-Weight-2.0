extends SpikeTrap

@onready var wall: StaticBody2D = %Wall

func _ready() -> void:
	_deactivated_frame = 4
	super()

func activate(_instant: bool = false) -> void:
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, true)
	super()
	

func deactivate(instant: bool = false) -> void:
	wall.call_deferred(CHANGE_WALL_COLLISION, WALL_COLLISION_LAYER, false)
	super()
