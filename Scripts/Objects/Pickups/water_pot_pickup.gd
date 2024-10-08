extends Pickup

@export var water_restoration_amount := 0.33

func setup_sprite() -> void:
	sprite = $AnimatedSprite2D

func collect() -> void:
	GameEvents.emit_water_collected(water_restoration_amount)
	super()
