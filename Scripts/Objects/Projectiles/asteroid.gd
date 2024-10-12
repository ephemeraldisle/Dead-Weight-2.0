class_name Asteroid
extends Projectile

@export var rotation_speed: float = 1.0
@export var size_variation: float = 0.2

func _ready() -> void:
    scale *= 1.0 + randf_range(-size_variation, size_variation)
    rotation = randf() * TAU

func _physics_process(delta: float) -> void:
    rotate(rotation_speed * delta)
    
    super._physics_process(delta)

func _handle_collision(collision: KinematicCollision2D, delta: float) -> void:
    # Add any asteroid-specific collision handling here
    # For example, you might want to split the asteroid into smaller pieces
    
    # Then call the parent class's _handle_collision
    super._handle_collision(collision, delta)