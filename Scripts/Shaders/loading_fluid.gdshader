shader_type canvas_item;

uniform float progress: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform vec4 bg_color: source_color;
uniform vec4 wave_1_color: source_color;
uniform vec4 wave_2_color: source_color;
uniform vec4 wave_2_color_b: source_color;
float SmoothCircle(vec2 uv,vec2 offset,float size){
                uv -= offset;
                uv/=size;
                float temp = clamp(1.-length(uv),0.,1.);
                return smoothstep(0.,1.,temp);
            }
float DrawBubble(vec2 uv,vec2 offset,float size){
   uv = (uv - offset)/size;
    float val = 0.;
    val = length(uv);
    val = smoothstep(0.5,2.,val)*step(val,1.);

    val +=SmoothCircle(uv,vec2(-0.2,0.3),0.6)*0.5;
    val +=SmoothCircle(uv,vec2(0.4,-0.5),0.2)*1.0;
    return val; 
}
vec2 Within(vec2 uv, vec4 rect) {
            return (uv-rect.xy)/(rect.zw-rect.xy);
}
            float Rand(float x)
            {
                return fract(sin(x*866353.13)*613.73);
            }
float DrawBubbles(vec2 uv){
                uv = Within(uv, vec4(-0.5,-0.5, 0.5, 0.5));
                uv.x -= 0.5;
				uv.y += 0.75;
                float val = 0.;
                const float count = 6.;// bubble num per second
                const float maxVY = 0.21;
                const float ay = -1.1;
                const  float ax = -15.5;
                const  float maxDeg = 80.;
                const float loopT = maxVY/ay + (1.- 0.5*maxVY*maxVY/ay)/maxVY;
                const  float num = loopT*count;
                for(float i=1.;i<num;i++){
                    float size = 0.02*Rand(i*69.420)+0.015;
                    float t = mod(TIME + Rand(i)*loopT,loopT)*(progress + 0.22);
                    float deg = radians((Rand(i*1354.54)*maxDeg + (90.-maxDeg*0.5)));
                    vec2 vel = vec2(cos(deg),sin(deg));
                    float ty = max((vel.y*0.3 - maxVY),0.)/ay;
                    float yt = clamp(t,0.,ty);
                    float y = max(0.,abs(vel.y)*yt + 0.5*ay*yt*yt) + max(0.,t-ty)*maxVY;// 加点加速度
        
                    float tx = abs(vel.x/ax);
                    t = min(tx,t);
                    float xOffset = abs(vel.x)*t+0.5*ax*t*t + sin(TIME*(0.5+Rand(i)*2.)+Rand(i)*2.*PI)*0.03;
                    float x = sign(vel.x)*xOffset;
                    vec2 offset = vec2(x,y);
                    val += DrawBubble(uv,offset,size*0.25);
                }
                return val;
            }


void fragment() {
	if (texture(TEXTURE, UV).rgb == vec3(1.0)){
		COLOR.a = 0.0;
	}
	else
	{vec2 uv = vec2(UV.x, -UV.y);
	
	
	float verticalBand = smoothstep(0.1, 0.9, sin(uv.x + (PI * 0.5)) - 1.0);
	float verticalBandAnimated = verticalBand * sin(TIME*4.0) * 0.01;
	
	float frontWave = (sin((TIME * 2.0 + uv.x) * 2.0) * 0.0075) + verticalBandAnimated+0.005;
	float backWave = (sin((TIME * -2.0 + uv.x) * 2.0+PI) * 0.006) - verticalBandAnimated-0.001;
	
	float fillAnimation = sin(TIME*3.0) * 0.0001 * verticalBand;
	
	float fillValue = mix(-0.2, progress - 1.0, step(0.0, 1.0));
	float fillProgress = fillValue + (sin(TIME*PI) * 0.0001);
	
	float frontFill = step(uv.y, fillAnimation + frontWave + fillProgress);
	float backFill = step(uv.y, -fillAnimation + backWave + fillProgress);
	
	vec3 wave_colored = vec3(frontFill) * mix(mix(wave_1_color.rgb, wave_2_color.rgb, -uv.y), wave_2_color_b.rgb, -uv.y*(1.-progress));
	vec3 wave_2_colored = vec3(backFill) * mix(mix(wave_2_color.rgb, wave_1_color.rgb, -uv.y), wave_2_color_b.rgb,-uv.y*(1.-progress));
	
	vec3 waves_color = mix(wave_colored, wave_2_colored, backFill);
	 //draw bubbles
    float bubbleMask = smoothstep(0.0,0.05,(progress * 1. +5.0)*0.5);
    waves_color += DrawBubbles(vec2(uv.x*.05, uv.y*1.0))*vec3(0.8)* bubbleMask;
	COLOR.rgb = mix(bg_color.rgb, waves_color, max(backFill, frontFill));
	if (max(backFill, frontFill) <= 0.0){
	COLOR.a = bg_color.a;}
	
		
	uv = vec2(0.5,0.5);
	}

	
}
