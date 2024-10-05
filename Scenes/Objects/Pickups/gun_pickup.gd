extends Pickup


func _ready():
#	if GameState.gun_enabled:
#		queue_free()
	super()

func setup_sprite() -> void:
	sprite = $Sprite2D

func collect() -> void:
	GameEvents.emit_gun_collected()
	super()

func on_area_entered(other_area: Area2D) -> void:
	GameState.unlock_gun()
	super(other_area)

##Why is unlock_gun on GameState?
