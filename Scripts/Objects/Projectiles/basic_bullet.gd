extends RigidBody2D

const ENEMY_GROUP := &"enemy"
const DAMAGE_METHOD := &"on_damage"
const VELOCITY_MULTIPLIER := 5000


@onready var timer = $Timer
@onready var fireball = $SpriteHolder
@onready var bounce: AudioStreamPlayer2D = $bounce


func _ready() -> void:
	timer.timeout.connect(queue_free)

func _physics_process(_delta) -> void:
	look_at(global_position + linear_velocity.normalized())
	constant_force = Vector2.ZERO
	constant_force = linear_velocity.normalized() * VELOCITY_MULTIPLIER


func _on_body_entered(body) -> void:
#	if body.is_in_group("tank") or body.is_in_group("enemy"):
	bounce.play()
	if body.is_in_group(ENEMY_GROUP):
		if body.has_method(DAMAGE_METHOD):
			body.on_damage()
		queue_free()

func player_take_damage(_meaningless: Vector2) -> void:
	queue_free()
