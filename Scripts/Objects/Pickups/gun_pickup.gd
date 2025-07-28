extends Pickup


func _ready():
#	if GameState.gun_enabled:
#		queue_free()
	super()

func setup_sprite() -> void:
	sprite = $Sprite2D

func collect() -> void:
	GameState.unlock_gun()
	GameEvents.emit_ability_access_changed("gun")
	super()

func on_area_entered(other_area: Area2D) -> void:
	super(other_area)
