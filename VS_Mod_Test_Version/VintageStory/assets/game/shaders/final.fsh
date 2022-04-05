#version 330 core

uniform sampler2D primaryScene;
uniform sampler2D glowParts;  // The second color buffer (outGlow var)
uniform sampler2D bloomParts; // The blurred find bright texture
uniform sampler2D godrayParts;
uniform sampler2D ssaoScene;

uniform float gammaLevel;
uniform float brightnessLevel;
uniform float sepiaLevel;
uniform float damageVignetting;
uniform float damageVignettingSide;
uniform float frostVignetting;
uniform float extraGamma = 1.0;
uniform float windWaveCounter;
uniform float glitchEffectStrength;

uniform float minlight = 0.0;
uniform float maxlight = 1;
uniform float minsat = 0;
uniform float maxsat = 1;


in vec2 invFrameSize;
in vec2 texCoord;
flat in float godrayIntensity;

layout(location = 0) out vec4 outColor;

#include fxaa.fsh
#include colorutil.ash
#include noise3d.ash

float SmoothStep(float x) { return x * x * (3.0f - 2.0f * x); }

vec4 ColorGrade(vec4 color) {
	// I don't know why, but this seems to make the scene look a lot better
	color.a = dot(color.rgb, vec3(0.299, 0.587, 0.114)); 
	
	vec3 hsl = rgb2hsl(color.rgb);

	float lightRange = maxlight - minlight;
	float satRange = maxsat - minsat;

	hsl.z = pow((clamp(hsl.z, minlight, maxlight) - minlight) / lightRange, 1/gammaLevel);
	hsl.y = pow((clamp(hsl.y, minsat, maxsat) - minsat) / satRange, 1);
	
	
	color.rgb = hsl2rgb(hsl);

	color.rgb = pow(color.rgb, vec3(1.0 / extraGamma));

	color.rgb *= brightnessLevel;

	// Sepia
	vec3 sepia = vec3(
		(color.r * 0.393) + (color.g * 0.769) + (color.b * 0.189),
		(color.r * 0.349) + (color.g * 0.686) + (color.b * 0.168),
		(color.r * 0.272) + (color.g * 0.534) + (color.b * 0.131)
	);
	
	color.rgb = mix(color.rgb, sepia, sepiaLevel);
	
	if (glitchEffectStrength > 0) {
		float g = gnoise(vec3(texCoord.x * 2000.0, texCoord.y * 2000.0, mod(windWaveCounter*30, 100)));
		color.rgb *= mix(1, clamp(0.7 + g / 2, 0.7, 1), glitchEffectStrength);
		
		vec3 rust = vec3(
			(color.r * 0.393) + (color.g * 0.769) + (color.b * 0.189),
			(color.r * 0.349) + (color.g * 0.686) + (color.b * 0.168),
			(color.r * 0.272) + (color.g * 0.534) + (color.b * 0.131)
		);
		
		float gdiff = min(color.g, 0.1);
		float bdiff = min(color.b, 0.1);
		rust.g -= gdiff;
		rust.b -= bdiff;
		rust.r += gdiff + bdiff;
		
		color.rgb = mix(color.rgb, rust, glitchEffectStrength);
		color.a += glitchEffectStrength/3;
	}
	

	
	
	// Limit brightness
	//float b = (color.r + color.b + color.g) / 3;
	//color.rgb /= max(1, b);
	//color.r = min(1, color.r);
	//color.b = min(1, color.b);
	//color.g = min(1, color.g);
	
	return color;	
}


void main(void)
{
	// FXAA precompiler constant is set by game engine
	#if FXAA == 1
		vec4 color = fxaaTexturePixel(primaryScene, texCoord, invFrameSize);
	#else
		vec4 color = texture(primaryScene, texCoord);
	#endif	
    
	color.a=1;
	float bloomSub = 0;
	#if BLOOM == 1
		vec4 bloomCol = texture(bloomParts, texCoord);
		float glowLevel = texture(glowParts, texCoord).r;
		
		float ambLevel = AMBIENTBLOOMLEVEL / 200.0;
		
		color.rgb = (color.rgb + bloomCol.rgb * (0.5+ambLevel/2)) / (1 + ambLevel);
		
		bloomSub = glowLevel * (bloomCol.r + bloomCol.b + bloomCol.g);
	#endif 

	#if SSAOLEVEL > 0
		color.rgb *= min(1, texture(ssaoScene, texCoord).r + bloomSub);
		//if (texCoord.x < 0.5) {
		  //color.rgb = texture(ssaoScene, texCoord).rgb;
		//}
	#endif
	
	
	#if GODRAYS > 0
		vec4 grc = texture(godrayParts, texCoord) * 1;
		color.rgb += grc.rgb;
		color.rgb = min(color.rgb, vec3(1));
		color.a=1;
	#endif
	
	vec4 gradedColor = ColorGrade(color);
	
	outColor = mix(color, gradedColor, gradedColor.a);
	


	// Vignetting
	vec2 position = (gl_FragCoord.xy * invFrameSize.xy) - vec2(0.5);
	float grayvignette = 1 - smoothstep(1.1, 0.75 - 0.45, length(position));
	
	
		
	if (frostVignetting > 0) {
		float str = -0.05 + 1.05*clamp(1 - smoothstep(1.1 - frostVignetting / 4, 0.75 - 0.45, length(position)), 0, 1) - grayvignette;
		float g = 0;
		
		float wx = gnoise(vec3(gl_FragCoord.x / 20.0, str, gl_FragCoord.x / 11.0 + gl_FragCoord.y / 10.0));
		float wy = gnoise(vec3(gl_FragCoord.x / 20.0, str, gl_FragCoord.x / 10.0 - gl_FragCoord.y / 9.0));
		
		g = 2*gnoise(vec3(wx / 3.0, wy / 3.0, 0.2)) + 0.8;
		g *= gnoise(vec3(gl_FragCoord.x / 20.0, gl_FragCoord.y / 20.0, 1.5)) + 0.2;
		g -= gnoise(vec3(wx * 2.0, wy * 2.0, 1))/5;
		g -= str*2;
		g *= frostVignetting;
		
		vec3 vignetteColor = vec3(0.9 + gnoise(vec3(wx, -wy, 0)) / 15.0, 0.9 + gnoise(vec3(wx, wy, 0)) / 15.0, 0.95);
		
		outColor.rgb = mix(outColor.rgb, vignetteColor, max(0, str - g) + 0.5*str);
	}
	
	
	
	if (damageVignetting > 0) {
		float str = clamp(1 - smoothstep(1.1 - damageVignetting / 4, 0.75 - 0.45, length(position)), 0, 1) - grayvignette;
		float g = 0;
		
		g = gnoise(vec3(gl_FragCoord.x / 20.0, gl_FragCoord.y / 20.0, 0)) + 0.5;
		g += gnoise(vec3(gl_FragCoord.x / 5.0, gl_FragCoord.y / 5.0, 0))/5;
		g -= str*2;
		
		g*=damageVignetting;
		
		vec3 vignetteColor = vec3(0.8 * damageVignetting/2, 0, 0);
		
		float centerness = pow(1 - abs(damageVignettingSide), 3);
		
		float side = clamp(centerness + pow(mix(texCoord.x, 1 - texCoord.x, (1 + damageVignettingSide) / 2), 1.5), 0, 1);
		
		outColor.rgb = mix(outColor.rgb, vignetteColor, max(0, str - g) * side);
	}
	
	outColor.rgb = mix(outColor.rgb, vec3(0), grayvignette);
	
	outColor.a=1;
}