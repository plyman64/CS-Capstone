#version 330 core

uniform sampler2D inputTexture;
uniform sampler2D glowParts;


in vec2 texCoord;
in vec3 sunPosScreen;
//in vec3 sunPos3d;
in float iGlobalTime;
in float intensity;
in float direction;

out vec4 outColor;


#include printvalues.fsh

// Falloff over distance
const float decay = 0.985; 

float hash( vec2 p ){ return fract(sin(dot(p, vec2(41, 289)))*45758.5453); }


vec4 applyGodRays(in vec2 uv, in vec3 nSunPos) {
	// Sample weight. Decays as we radiate outwards.
	float weight = intensity / 10.0;
	
	vec2 tuv = uv - 0.5 - nSunPos.xy * 0.45;
	
	vec2 dTuv = tuv * intensity / 64 * direction;
	
	// When looking 90 degrees away from the sun, dTuv gets very large and causes significant frame drops.
	// I presume this is because the graphics card local texture cache is no longer effective due to the large uv coord jumps
	if (length(dTuv) > 0.005) {
		dTuv = normalize(dTuv) * 0.005;
	}
	
	float glow = texture(glowParts, uv).g;
    vec4 col = texture(inputTexture, uv) * glow;
	
    uv += dTuv * (hash(uv.xy + fract(iGlobalTime)) * .5 - 0.25);
    
	int samples = int(180 * min(1, intensity * 1.2));
	
    for (float i=0.0; i < samples; i++) {
        uv -= dTuv;
		uv.x = clamp(uv.x, 0, 1);
		uv.y = clamp(uv.y, 0, 1);
        col += texture(inputTexture, uv) * texture(glowParts, uv).g * weight;
        weight *= decay;
    }
	
	//col = mix(col, vec4(0.0, 0.5, 0.0, 1), PrintValue(gl_FragCoord.xy, grid(0,1), fontSize, tuv.x, 1.0, 3.0));
	//col = mix(col, vec4(0.0, 0.5, 0.0, 1), PrintValue(gl_FragCoord.xy, grid(0,0), fontSize, tuv.y, 1.0, 3.0));
    
	col.a = min(1, col.a);
	col.rgb -= vec3(max(0, glow - 0.35));
	
	//col = clamp(col, vec4(0), vec4(1));
	//col.rgb *= 1 - max((col.r+col.g+col.b)/3 - 0.3, 0);
	
    return col;
}


void main(void) {
	vec3 nSunPos = clamp(sunPosScreen, -10, 10);
	
	outColor = applyGodRays(texCoord, nSunPos);
	outColor.a=1;
}