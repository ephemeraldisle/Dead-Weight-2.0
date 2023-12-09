shader_type canvas_item;

uniform float squeeze_amount: hint_range(0.0, 1.0, 0.05) = 0.5;

void fragment() {
 	vec2 uv = UV;
    float squeeze = squeeze_amount * (0.5 - abs(uv.y - 0.5));
    uv.x = mix(uv.x, uv.x + squeeze * (uv.x - 0.5), squeeze_amount);
    vec4 tex_color = texture(TEXTURE, uv);
    
    if (uv.x < -0.1) {
        float alpha_fade = 1.0 - smoothstep(-0.1, -0.2, uv.x);
        tex_color.a *= alpha_fade;
    } else if (uv.x > 1.1) {
        float alpha_fade = 1.0 - smoothstep(1.1, 1.2, uv.x);
        tex_color.a *= alpha_fade;
    }
    
    COLOR = tex_color;
}
