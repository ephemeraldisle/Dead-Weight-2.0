extends StaticBody2D

const FIRST_Y_ADJUSTMENT = 50
const SECOND_Y_ADJUSTMENT = 70
const MAX_HITS = 4
const INVINCIBILITY_TIME = 0.5

@export var linked_objects_start_active: Array[Node2D]
@export var linked_objects_start_deactive: Array[Node2D]

var _times_hit := 0
var _damageable := true

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var particles = preload("res://Scenes/Particles/power_node_hit_particles.tscn")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var toggler_component = $TogglerComponent as Toggler

@onready var original_shape_position = collision_shape_2d.position


func _ready() -> void:
	toggler_component.register_active_objects(linked_objects_start_active)
	toggler_component.register_inactive_objects(linked_objects_start_deactive)
	toggler_component.toggled_from_save.connect(check_save_data)
	check_save_data()


func update_appearance_and_hitbox() -> void:
	animated_sprite_2d.frame = _times_hit
	match _times_hit:
		0:
			collision_shape_2d.position = original_shape_position
		2:
			collision_shape_2d.position.y = original_shape_position.y + FIRST_Y_ADJUSTMENT
		MAX_HITS:
			collision_shape_2d.position.y = original_shape_position.y + SECOND_Y_ADJUSTMENT


func check_save_data() -> void:
#	print("%s checking save" %get_path())
	if toggler_component.toggled:
		_times_hit = 0
		_damageable = true
	else:
		_times_hit = MAX_HITS
		_damageable = false
	update_appearance_and_hitbox()


func on_damage() -> void:
	if !_damageable:
		return
	_times_hit = min(_times_hit + 1, MAX_HITS)

	var particles_instance = particles.instantiate()
	add_child(particles_instance)
	particles_instance.emitting = true
	audio_stream_player_2d.play()
	update_appearance_and_hitbox()

	if _times_hit == MAX_HITS:
		toggler_component.set_off()
		_damageable = false
	else:
		invicibilty_frames()


func invicibilty_frames() -> void:
	_damageable = false
	await get_tree().create_timer(INVINCIBILITY_TIME, false, true).timeout
	_damageable = true
