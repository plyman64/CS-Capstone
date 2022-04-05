#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout(location = 0) in vec3 vertexPositionIn;
layout(location = 1) in vec2 uvIn;
layout(location = 2) in vec4 modelColor;
layout(location = 3) in int flags;

uniform vec3 rgbaAmbientIn;
uniform vec4 rgbaLightIn;
uniform vec4 rgbaGlowIn;
uniform int extraGlow;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

out vec2 uv;
out vec4 color;

out vec3 normal;
out vec3 vertexPosition;
#if SSAOLEVEL > 0
out vec4 fragPosition;
out vec4 gnormal;
#endif



#include vertexflagbits.ash
#include shadowcoords.vsh
#include fogandlight.vsh

void main(void)
{
	vec4 cameraPos = modelViewMatrix * vec4(vertexPositionIn, 1.0);
	
	int glow = min(255, extraGlow + (flags & GlowLevelBitMask));
	glowLevel = glow / 255.0;
	
	uv = uvIn;
	color = applyLight(
		rgbaAmbientIn, 
		rgbaLightIn, 
		glow,
		cameraPos
	) * modelColor;
	
	color.rgb = mix(color.rgb, rgbaGlowIn.rgb, glow / 255.0 * rgbaGlowIn.a);
	
	gl_Position = projectionMatrix * cameraPos;
	
	normal = unpackNormal(flags);
	normal = normalize((modelViewMatrix * vec4(normal.x, normal.y, normal.z, 0)).xyz);

	#if SSAOLEVEL > 0
		fragPosition = cameraPos;
		gnormal = vec4(normal, 0);
	#endif	
}