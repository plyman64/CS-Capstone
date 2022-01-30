#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

in vec2 uv;
in vec4 color;
in vec4 rgbaFog;
in float fogAmount;
in float glowLevel;

layout(location = 0) out vec4 outAccu;
layout(location = 1) out vec4 outReveal;
layout(location = 2) out vec4 outGlow;

uniform sampler2D entityTex;
uniform float alphaTest = 0.001;

#include fogandlight.fsh


void drawPixel(vec4 color) {
	float weight = color.a * clamp(0.03 / (1e-5 + pow(gl_FragCoord.z / 200, 4.0)), 1e-2, 3e3);
	
    // RGBA32F texture (accumulation)
    outAccu = vec4(color.rgb * color.a, color.a) * weight;
	
    // R32F texture (revealage)
    // Make sure to use the red channel (and GL_RED target in your texture)
    outReveal.r = color.a;

    outGlow = vec4(glowLevel, 0, 0, color.a);
}


void main () {
	vec4 texColor = applyFogAndShadow(texture(entityTex, uv) * color, fogAmount);
	
	if (texColor.a < alphaTest) discard;
	
	outGlow = vec4(20, 0, 0, 1);
	
	//drawPixel(applyFogAndShadow(texColor * color, fogAmount));
	drawPixel(vec4(0.5));
}