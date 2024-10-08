extends Pickup

@export var energy_restoration_amount := 4.0

@onready var animation_player := $AnimationPlayer

func setup_sprite() -> void:
	sprite = $AnimatedSprite2D

func collect() -> void:
	GameEvents.emit_energy_collected(energy_restoration_amount)
	super()

func on_area_entered(other_area: Area2D) -> void:
	animation_player.stop()
	super(other_area)

