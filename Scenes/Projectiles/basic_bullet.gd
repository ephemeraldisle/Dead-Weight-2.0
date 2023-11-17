extends RigidBody2D
@onready var timer = $Timer
@onready var fireball = $SpriteHolder
@onready var bounce: AudioStreamPlayer2D = $bounce




func _ready():
	timer.timeout.connect(queue_free)

func _physics_process(_delta):
	look_at(global_position + linear_velocity.normalized())
	constant_force = Vector2.ZERO
	constant_force = linear_velocity.normalized()*5000



func _on_body_entered(body):
#	if body.is_in_group("tank") or body.is_in_group("enemy"):
	bounce.play()
	if body.is_in_group("enemy"):
		if body.has_method("on_damage"):
			body.on_damage()
		queue_free()

func player_take_damage(_meaningless: Vector2) -> void:
	queue_free()
