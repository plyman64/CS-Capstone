#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout (location = 0) in vec3 vertexPosition;		// Per vertex
layout (location = 1) in vec4 normalv;				// Per vertex
layout (location = 2) in vec2 uv;						// Per vertex

layout (location = 3) in int renderFlags; 			// Per instance
layout (location = 4) in vec3 particlePosition; 	// Per instance (=per particle)
layout (location = 5) in float scale;					// Per instance
layout (location = 6) in vec4 rgbaLightIn; 		// Per instance
layout (location = 7) in vec4 rgbaBlockIn; 		// Per instance
layout (location = 8) in vec4 particleDir; 			// Per instance

uniform vec4 rgbaFogIn;
uniform vec3 rgbaAmbientIn;	
uniform float fogMinIn;
uniform float fogDensityIn;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

out vec4 color;
out vec4 rgbaFog;
out vec3 normal;
out float fogAmount;
#if SSAOLEVEL > 0
out vec4 fragPosition;
out vec4 gnormal;
#endif

#include vertexflagbits.ash
#include shadowcoords.vsh
#include fogandlight.vsh
#include vertexwarp.vsh

void main()
{
	vec4 worldPos = vec4(vertexPosition * scale + particlePosition, 1.0);
	
	worldPos = applyVertexWarping(renderFlags, worldPos);
	
	vec4 cameraPos = modelViewMatrix * worldPos;
	gl_Position = projectionMatrix * cameraPos;
	
	int flags = min(255, 2 * (renderFlags & 0xff)); // increase the glow on cube particles
	color = applyLight(rgbaAmbientIn, rgbaLightIn, flags, cameraPos) * rgbaBlockIn;
	
	fogAmount = getFogLevel(vec4(particlePosition, 0), fogMinIn, fogDensityIn);
	rgbaFog = rgbaFogIn;
	normal = normalv.xyz;
	
	calcShadowMapCoords(modelViewMatrix, worldPos);
	
#if SSAOLEVEL > 0
	
	fragPosition = cameraPos;
	gnormal = modelViewMatrix * vec4(normal.xyz, 0.25);
#endif
} 