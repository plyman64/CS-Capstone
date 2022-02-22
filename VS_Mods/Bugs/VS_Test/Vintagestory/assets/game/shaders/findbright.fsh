#version 330 core

uniform sampler2D colorTex;
uniform sampler2D glowTex;
uniform float extraBloom;

in vec2 texcoord;

out vec4 outColor;

void main(void)
{
	vec4 color = texture(colorTex, texcoord);
	float glowLevel = texture(glowTex, texcoord).r;
	float bloomIntensity = AMBIENTBLOOMLEVEL / 100.0 + 3*glowLevel + extraBloom;
	
	outColor = color * bloomIntensity;
}