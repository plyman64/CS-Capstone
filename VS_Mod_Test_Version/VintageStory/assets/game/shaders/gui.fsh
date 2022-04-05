#version 330 core

in vec2 uv;
in vec4 color;
in float glowLevel;
in vec2 clipPos;


out vec4 outColor;
in vec4 rgbaGlow;

uniform float noTexture;
uniform float alphaTest;
uniform int darkEdges;
uniform int tempGlowMode;
uniform int transparentCenter;
uniform sampler2D tex2d;
uniform int normalShaded;
uniform float sepiaLevel = 0;

// Texture overlay "hack"
// We only have the base texture UV coordinates, which, for blocks and items in inventory is the block or item texture atlas, but none uv coords for a dedicated overlay texture
// So lets remove the base offset (baseUvOrigin) and rescale the coords (baseTextureSize / overlayTextureSize) to get useful UV coordinates for the overlay texture
uniform sampler2D tex2dOverlay;
uniform float overlayOpacity;
uniform vec2 overlayTextureSize;
uniform vec2 baseTextureSize;
uniform vec2 baseUvOrigin;


in float normalShadeIntensity;
flat in vec3 normal;


#include vertexflagbits.ash
#include normalshading.fsh


void main () {
	if (darkEdges > 0) {
		float dx = 1.7 * abs(uv.x - 0.5) - 0.7;
		float dy = 1.7 * abs(uv.y - 0.5) - 0.7;
		float strength = clamp(max(dx,dy) * 0.85 + (1- (dx*dx + dy*dy)) * 0.15, 0, 0.5);
		
		outColor = vec4(0,0,0, strength);
		return;
	}

	if (noTexture > 0) {
		outColor = color;
	} else {
		if (overlayOpacity > 0) {
			vec2 uvOverlay = (uv - baseUvOrigin) * (baseTextureSize / overlayTextureSize);
		
			vec4 col1 = texture(tex2dOverlay, uvOverlay);
			vec4 col2 = texture(tex2d, uv);
			
			float a1 = overlayOpacity * col1.a  * min(1, col2.a * 100);
			float a2 = col2.a * (1 - a1);
			
			outColor = vec4(
				(a1 * col1.r + col2.r * a2) / (a1+a2),
				(a1 * col1.b + col2.g * a2) / (a1+a2),
				(a1 * col1.g + col2.b * a2) / (a1+a2),
				a1 + a2
			) * color;
			
			
		} else {
			outColor = texture(tex2d, uv) * color;
		}
	}
	
	
	if (tempGlowMode == 1) {
		outColor.rgb += rgbaGlow.rgb * min(0.8, glowLevel + rgbaGlow.a);
	} else {
		outColor.rgb *= 1 + glowLevel;
	}
	
	if (transparentCenter > 0) {
		outColor.a *= clamp(pow(length(clipPos), 2) * 15, 0, 1);
	}
	
	if (outColor.a <= alphaTest) discard;
	
	if (normalShaded > 0) {
		float b = getBrightnessFromNormal(normal, normalShadeIntensity, 0.45) * 1.2;
		outColor *= vec4(b, b, b, 1);
	}
	
	if (sepiaLevel > 0) {
		// Sepia
		vec3 sepia = vec3(
			(outColor.r * 0.393) + (outColor.g * 0.769) + (outColor.b * 0.189),
			(outColor.r * 0.349) + (outColor.g * 0.686) + (outColor.b * 0.168),
			(outColor.r * 0.272) + (outColor.g * 0.534) + (outColor.b * 0.131)
		);
		
		outColor.rgb = mix(outColor.rgb, sepia * 1.33, sepiaLevel);
	}
	
	//outColor.a=0.1;
}

