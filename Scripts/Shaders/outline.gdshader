shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 100) = 1.0;
uniform float buffer: hint_range(0,100) = 10.0;
uniform float angular_speed : hint_range(-5.0, 5.0, 0.01) = 2.5;
uniform float radial_speed : hint_range(-5.0, 5.0, 0.01) = 1.4;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool add_margins = true;
uniform vec2 number_of_images = vec2(1.0); // number of horizontal and vertical images in the sprite sheet
uniform sampler2D noise;

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 image_top_left, vec2 image_bottom_right, sampler2D texture, out float minimum_distance) {
	float combo_width = width + buffer;
	minimum_distance = combo_width;
	for (float i = -ceil(combo_width); i <= ceil(combo_width); i++) {

		float x = abs(i) > combo_width ? combo_width * sign(i) : i;
		float offset;

		if (pattern == 0) {
			offset = combo_width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(combo_width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = combo_width;
		}

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
	
			if ((xy != clamp(xy, image_top_left, image_bottom_right) || texture(texture, xy).a <= 0.0) == false) {
				minimum_distance = min(minimum_distance, length(vec2(x, y)));
			}
		}
	}
	
	if (minimum_distance <= buffer){
		minimum_distance = combo_width-minimum_distance*(width*0.1);
		return true;
	}

	if (minimum_distance != combo_width){ 
		return true;
	}

	return false;
}

float easeInOutCubic(float t) {
  return t < 0.5
    ? 4.0 * t * t * t
    : 0.5 * pow(2.0 * t - 2.0, 3.0) + 1.0;
}

void vertex() {
	
	if (add_margins) {
		VERTEX += sign(VERTEX) * (width + buffer); // replace `sign(VERTEX)` by `sign(VERTEX * 2.0 - 1.0)` if not centered
	}
}

void fragment() {

	vec2 uv = UV;
	vec2 image_top_left = floor(uv * number_of_images) / number_of_images;
	vec2 image_bottom_right = image_top_left + vec2(1.0) / number_of_images;

	if (add_margins) {
		vec2 texture_pixel_size = vec2(1.0) / (vec2(1.0) / TEXTURE_PIXEL_SIZE + vec2((buffer+width) * 2.0) * number_of_images);

		uv = (uv - texture_pixel_size * (width+buffer) - image_top_left) * TEXTURE_PIXEL_SIZE / texture_pixel_size + image_top_left;

		if (uv != clamp(uv, image_top_left, image_bottom_right)) {
			COLOR.a = 0.0;
		} else {
			COLOR = texture(TEXTURE, uv);
		}
	} else {
		COLOR = texture(TEXTURE, uv);
	}

	float dist;
	
	if ((COLOR.a <= 0.0) && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, image_top_left, image_bottom_right, TEXTURE, dist)) {
		float angle = atan(uv.x, uv.y) + (TIME * angular_speed);
		vec2 polar = fract(vec2(angle / 6.28, length(uv)*2.0 + (TIME * radial_speed)));
		
		
		float noise_change = texture(noise, polar).b; // sample the red channel of the noise texture
        dist += noise_change * 10.0 - 5.0;
		
		float gradient_alpha = 1.0 - easeInOutCubic((dist) / (width+buffer));
		COLOR.rgb = color.rgb;
		if (color.a == 0.0){
			COLOR.a = color.a;
		}		
		else{
			COLOR.a = gradient_alpha;}
	}
}