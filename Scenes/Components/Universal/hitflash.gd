extends Node

const SCALE_MULTIPLIER := 1.15
const TWEEN_DURATION := 0.45
const INITIAL_LERP_PERCENT := 1.0
const FINAL_LERP_PERCENT := 0.0
const SHADER_LERP_PARAM := "lerp_percent"
const LERP_PARAM_PATH := "shader_parameter/lerp_percent"

@export var health_component: Node
@export var sprites: Array[Node2D] = []
@export var material: ShaderMaterial

var hit_flash_tween: Tween
var parent: Node

func _ready() -> void:
	health_component.damaged.connect(_on_health_changed)
	parent = get_parent()
	_apply_material_to_sprites()

func _apply_material_to_sprites() -> void:
	for sprite in sprites:
		if sprite != null:
			sprite.material = material

func _on_health_changed() -> void:
	if hit_flash_tween and hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	
	hit_flash_tween = create_tween()
	hit_flash_tween.set_parallel()
	
	_tween_parent_scale()
	_tween_sprite_materials()

func _tween_parent_scale() -> void:
	var original_scale: Vector2 = parent.scale
	parent.scale = original_scale * SCALE_MULTIPLIER
	hit_flash_tween.tween_property(parent, g.SCALE, original_scale, TWEEN_DURATION) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_BACK)

func _tween_sprite_materials() -> void:
	for sprite in sprites:
		var shader_material := sprite.material as ShaderMaterial
		shader_material.set_shader_parameter(SHADER_LERP_PARAM, INITIAL_LERP_PERCENT)
		hit_flash_tween.tween_property(shader_material, LERP_PARAM_PATH, FINAL_LERP_PERCENT, TWEEN_DURATION) \
			.set_ease(Tween.EASE_IN_OUT) \
			.set_trans(Tween.TRANS_BOUNCE)