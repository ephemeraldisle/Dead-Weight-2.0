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
	if (COLOR.r >= 0.70){
		COLOR = generic_desaturate(COLOR.rgb, 1.0);
		float offset = FRAGCOORD.x*0.001;
		vec4 mix_color = vec4(mix(color_a, color_b, (sin((TIME+offset)*speed_factor)+1.0)*0.75));
		COLOR.rgb = vec3(mix(COLOR.rgb, mix_color.rgb, 0.75));
	}
}
