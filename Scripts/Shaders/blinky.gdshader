shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0);

void fragment() {

	float threshold = 1.0;
	
	float comparer = mod(TIME, 4);
	if (comparer < 3.5){
		threshold = 1.0;
	}
	else if (comparer < 3.65){
		threshold = 1.0-(comparer-3.5)*4.0;
	}
	else{
		threshold = (comparer-3.6)*2.5;
	}
	
	threshold = clamp(threshold, 0.005, 1.0);
	
	
	
	if (COLOR.a < threshold){
		COLOR.a = 0.0;
	}
	else {
		COLOR = color;
	}
}
