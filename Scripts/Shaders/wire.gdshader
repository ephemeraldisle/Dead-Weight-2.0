shader_type canvas_item;

uniform vec4 color_a: source_color;
uniform vec4 color_b: source_color;
uniform float speed_factor: hint_range(0.1, 100.0, 0.1) = 3.0;

vec4 generic_desaturate(vec3 colour, float factor) { 
	vec3 lum = vec3(0.299, 0.587, 0.114); 
	vec3 gray = vec3(dot(lum, colour)); 
	return vec4(mix(colour, gray, factor), 1.0); 
}



void fragment() {
	if (COLOR.g >= 0.20 && COLOR.r <= 0.9){
		COLOR = generic_desaturate(COLOR.rgb, 1.0)*0.5;
		float offset = UV.x*0.5;
		vec4 mix_color = vec4(mix(color_a, color_b, (sin((TIME-offset)*speed_factor*0.5)+1.0)*0.75));
		COLOR.rgb = vec3(mix(COLOR.rgb, mix_color.rgb, 0.25));
	}
	else if (COLOR.a > 0.0){
		COLOR = generic_desaturate(COLOR.rgb, 1.0);
		float offset = UV.x*0.1;
		vec4 mix_color = vec4(mix(color_b, color_a, (sin((TIME-offset)*speed_factor*2.5)+1.0)*1.0));
		COLOR.rgb = vec3(mix(COLOR.rgb, mix_color.rgb, 0.25));
	}
}
