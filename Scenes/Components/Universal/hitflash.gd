extends Node

@export var health_component: Node
@export var sprites: Array[Node2D] = []
@export var material: ShaderMaterial

var hit_flash_tween: Tween
var parent
func _ready():
	health_component.damaged.connect(on_health_changed)
	parent = get_parent()
	for sprite in sprites:
		if sprite != null:
			sprite.material = material
#
func on_health_changed():
	if hit_flash_tween != null and hit_flash_tween.is_valid():
		hit_flash_tween.kill()
	
	hit_flash_tween = create_tween()
	hit_flash_tween.set_parallel()
	var original_scale = parent.scale
	parent.scale = original_scale * 1.15
	hit_flash_tween.tween_property(parent, "scale", original_scale, 0.45).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	
	for sprite in sprites:
		(sprite.material as ShaderMaterial).set_shader_parameter("lerp_percent", 1.0)
		hit_flash_tween.tween_property(sprite.material, "shader_parameter/lerp_percent", 0.0, .45).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
		
