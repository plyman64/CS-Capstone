#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout(location = 0) in vec3 vertexPos;
layout(location = 1) in vec2 decalUvIn;
// rgb = block light, a=sun light level
layout(location = 2) in vec4 rgbaLightIn;
layout(location = 3) in int renderFlagsIn;
layout(location = 4) in vec2 blockUvIn;
layout(location = 5) in vec2 decalUvSizeIn;
layout(location = 6) in vec2 decalUvStartIn; // Argh >.<


uniform vec4 rgbaFogIn;
uniform vec3 rgbaAmbientIn;
uniform float fogDensityIn;
uniform float fogMinIn;
uniform vec3 origin;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

out vec2 decalUv;
out vec2 blockUv;
out vec2 decalUvSize;
out vec2 decalUvStart;
out vec4 color;

#include vertexflagbits.ash
#include shadowcoords.vsh
#include fogandlight.vsh
#include vertexwarp.vsh

void main () {
	vec4 worldpos = vec4(vertexPos + origin, 1.0);
	
	worldpos = applyVertexWarping(renderFlagsIn, worldpos);
	
	vec4 cameraPos = modelViewMatrix * worldpos;

	gl_Position = projectionMatrix * cameraPos;
	
	
	color = applyLight(rgbaAmbientIn, rgbaLightIn, renderFlagsIn, cameraPos);
	color = applyFog(worldpos, color, rgbaFogIn, fogMinIn, fogDensityIn);
	color.a = 1;
	
	// We pretend the decal is closer to the camera to enforce it
	// always being drawn on top
	gl_Position.w += 0.0012;

	decalUv = decalUvIn;
	blockUv = blockUvIn;
	decalUvSize = decalUvSizeIn;
	decalUvStart = decalUvStartIn;
}