shader_type canvas_item;

uniform vec4 color: source_color = vec4(1.0);

const float CYCLE_TIME = 4.0;
const float OPEN_TIME = 3.5;
const float CLOSING_TIME = 3.65;
const float CLOSING_MULTI = 4.0;
const float OPENING_START = 3.6;
const float OPENING_MULTI = 2.5;
const float ROUNDED_ZERO = 0.005;

void fragment() {

	float threshold = 1.0;
	float comparer = mod(TIME, CYCLE_TIME);
	
	if (comparer < OPEN_TIME){
		threshold = 1.0;
	}
	else if (comparer < CLOSING_TIME){
		threshold = 1.0 - (comparer - OPEN_TIME) * CLOSING_MULTI;
	}
	else{
		threshold = (comparer - OPENING_START) * OPENING_MULTI;
	}
	
	threshold = clamp(threshold, ROUNDED_ZERO, 1.0);
	
	if (COLOR.a < threshold){
		COLOR.a = 0.0;
	}
	else {
		COLOR = color;
	}
}
