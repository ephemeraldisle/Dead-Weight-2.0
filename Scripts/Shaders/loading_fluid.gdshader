shader_type canvas_item;

uniform float aspect_ratio = 0.05;
uniform float progress: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec4 bg_color: source_color;
uniform vec4 wave_1_color: source_color;
uniform vec4 wave_2_color: source_color;
uniform vec4 wave_mix_color: source_color;


const vec3 BUBBLE_COLOR = vec3(0.8);

const float ARBITRARY_RANDOM_1 = 866353.13;
const float ARBITRARY_RANDOM_2 = 613.73;
const float ARBITRARY_RANDOM_3 = 420.69;
const float ARBITRARY_RANDOM_4 = 1354.54;

const float BUBBLE_MIN_SIZE = 0.5;
const float BUBBLE_MAX_SIZE = 2.0;
const vec2 HIGHLIGHT_1_POS = vec2(-0.2,0.3);
const float HIGHLIGHT_1_SIZE = 0.6;
const float HIGHLIGHT_1_MULTI = 0.5;
const vec2 HIGHLIGHT_2_POS = vec2(0.4,-0.5);
const float HIGHLIGHT_2_SIZE = 0.2;
const float HIGHLIGHT_2_MULTI = 1.0;
const float RECTANGLE_X_SIZE = 0.5;
const float RECTANGLE_Y_SIZE = 0.5;
const float RECTANGLE_X_OFFSET = -0.5;
const float RECTANGLE_Y_OFFSET = 0.75;

const float BUBBLES_PER_SEC = 6.0;
const float MAX_Y_VELOCITY = 0.21;
const float Y_ACCELERATION = -1.1;
const float X_ACCELERATION = -15.5;
const float MAX_DEGREES = 80.0;

const float BUBBLE_SIZE_MULTI = 0.02;
const float BUBBLE_SIZE_CONST = 0.015;

const float LIFETIME_CONST = 0.22;
const float INITIAL_Y_VEL_MULTI = 0.3;

const float FINAL_SIZE_MULTI = 0.25;
const float BUB_X_SIN_CONST = 0.5;
const float BUB_X_SIN_MULTI = 2.0;
const float X_OFFSET_MULTI = 0.03;

const vec2 WAVE_BAND_RANGE = vec2(0.1, 0.9);
const float WAVE_BAND_SIN_MULTI = 0.5;
const float WAVE_BAND_CONST = -1.0;
const float ANIM_SIN_MULTI = 4.0;
const float ANIM_MULTI = 0.01;

const float WAVE_TIME_MULTI = 2.0;
const float WAVE_SIN_MULTI = 2.0;
const float FRONT_WAVE_MULTI = 0.0075;
const float BACK_WAVE_MULTI = 0.006;
const float FRONT_WAVE_CONST = 0.005;
const float BACK_WAVE_CONST = -0.001;
const float FILL_TIME_MULTI = 3.0;
const float FILL_MULTI = 0.0001;
const float FILL_MIN = -0.2;
const float FILL_MAX = 1.0;
const float FILL_PROGRESS_MULTI = 0.0001;


float smooth_circle(vec2 uv, vec2 offset, float size){
    uv -= offset;
    uv /= size;
    float temp = clamp(1.0 - length(uv), 0.0, 1.0);
    return smoothstep(0.0, 1.0, temp);
}

float draw_bubble(vec2 uv, vec2 offset, float size){
    uv = (uv - offset) / size;
    float value = length(uv);
    float bubble = smoothstep(BUBBLE_MIN_SIZE, BUBBLE_MAX_SIZE, value) * step(value, 1.0);
    float highlight_1 = smooth_circle(uv, HIGHLIGHT_1_POS, HIGHLIGHT_1_SIZE)*HIGHLIGHT_1_MULTI;
    float highlight_2 = smooth_circle(uv, HIGHLIGHT_2_POS, HIGHLIGHT_2_SIZE)*HIGHLIGHT_2_MULTI;
    bubble += highlight_1;
    bubble += highlight_2;
    return bubble; 
}

vec2 within(vec2 uv, vec4 rect) {
     return (uv - rect.xy) / (rect.zw - rect.xy);
}

float rand(float x){
    return fract(sin(x * ARBITRARY_RANDOM_1) * ARBITRARY_RANDOM_2);
}

float draw_bubbles(vec2 uv){
    uv.x *= aspect_ratio;
    uv = within(uv, vec4(-RECTANGLE_X_SIZE, -RECTANGLE_Y_SIZE, RECTANGLE_X_SIZE, RECTANGLE_Y_SIZE));
    uv += vec2(RECTANGLE_X_OFFSET, RECTANGLE_Y_OFFSET);
    float bubbles = 0.0;
    const float offset_degrees = 90.0 - MAX_DEGREES * 0.5;
    const float acceleration_time = MAX_Y_VELOCITY / Y_ACCELERATION;
    const float acceleration_distance = (1.0 - 0.5 * MAX_Y_VELOCITY * acceleration_time);
    const float travel_distance = acceleration_distance / MAX_Y_VELOCITY;
    const float bubble_life_time = acceleration_time + travel_distance;
    const float num = bubble_life_time*BUBBLES_PER_SEC;

    for(float i = 1.0; i < num; i++){
        float size = BUBBLE_SIZE_MULTI * rand(i * ARBITRARY_RANDOM_3) + BUBBLE_SIZE_CONST;
        float time = mod(TIME + rand(i) * bubble_life_time, bubble_life_time) * (progress + LIFETIME_CONST);
        float angle = radians((rand(i * ARBITRARY_RANDOM_4) * MAX_DEGREES + offset_degrees));
        vec2 velocity = vec2(cos(angle), sin(angle));
        float time_to_accel = max((velocity.y*INITIAL_Y_VEL_MULTI - MAX_Y_VELOCITY), 0.0) / Y_ACCELERATION;
        float elapsed_time = clamp(time, 0.0, time_to_accel);
        float y = max(0.0, abs(velocity.y) * elapsed_time + 0.5 * Y_ACCELERATION * pow(elapsed_time, 2.0))
                + max(0.0, time - time_to_accel) * MAX_Y_VELOCITY;
        float horizontal_time = abs(velocity.x / X_ACCELERATION);
        time = min(horizontal_time, time);
        float xOffset = abs(velocity.x) * time + 0.5 * X_ACCELERATION * pow(time, 2.0)
                + sin(TIME*(BUB_X_SIN_CONST + rand(i) * BUB_X_SIN_MULTI) 
                + rand(i) * BUB_X_SIN_MULTI * PI) * X_OFFSET_MULTI;
        float x = sign(velocity.x) * xOffset;
        vec2 offset = vec2(x, y);
        bubbles += draw_bubble(uv, offset, size * FINAL_SIZE_MULTI);
    }
    return bubbles;
}


void fragment() {
	if (texture(TEXTURE, UV).rgb == vec3(1.0)){
		COLOR.a = 0.0;
	}
	else{
        vec2 uv = vec2(UV.x, -UV.y);
        
        
        float vertical_band = smoothstep(WAVE_BAND_RANGE.x, WAVE_BAND_RANGE.y, sin(uv.x + (PI * WAVE_BAND_SIN_MULTI)) - WAVE_BAND_CONST);
        float vertical_band_animated = vertical_band * sin(TIME*ANIM_SIN_MULTI) * ANIM_MULTI;
        
        float front_wave = (sin((TIME * WAVE_TIME_MULTI + uv.x) * WAVE_SIN_MULTI) * FRONT_WAVE_MULTI) + vertical_band_animated + FRONT_WAVE_CONST;
        float back_wave = (sin((TIME * -WAVE_TIME_MULTI + uv.x) * WAVE_SIN_MULTI + PI) * BACK_WAVE_MULTI) - vertical_band_animated - BACK_WAVE_CONST;
        
        float fill_animation = sin(TIME * FILL_TIME_MULTI) * FILL_MULTI * vertical_band;
        
        float fill_value = mix(FILL_MIN, progress - FILL_MAX, step(0.0, 1.0));
        float fill_progress = fill_value + (sin(TIME * PI) * FILL_PROGRESS_MULTI);
        
        float front_fill = step(uv.y, fill_animation + front_wave + fill_progress);
        float back_fill = step(uv.y, -fill_animation + back_wave + fill_progress);
        
        vec3 wave_colored = vec3(front_fill) * mix(mix(wave_1_color.rgb, wave_2_color.rgb, -uv.y), wave_mix_color.rgb, -uv.y * (1.0 - progress));
        vec3 wave_2_colored = vec3(back_fill) * mix(mix(wave_2_color.rgb, wave_1_color.rgb, -uv.y), wave_mix_color.rgb, -uv.y * (1.0 - progress));
        
        vec3 waves_color = mix(wave_colored, wave_2_colored, back_fill);
 
        
        waves_color += draw_bubbles(uv) * BUBBLE_COLOR;
        COLOR.rgb = mix(bg_color.rgb, waves_color, max(back_fill, front_fill));
        
        if (max(back_fill, front_fill) <= 0.0){
            COLOR.a = bg_color.a;
        }
	}	
}