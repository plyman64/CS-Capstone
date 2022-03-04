#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout(location = 0) in vec3 vertexPositionIn;
layout(location = 1) in vec2 uvIn;
layout(location = 2) in vec4 colorIn;
layout(location = 3) in int flags;
layout(location = 4) in int jointId;

uniform vec3 rgbaAmbientIn;
uniform vec4 rgbaLightIn;
uniform vec4 rgbaFogIn;
uniform float fogMinIn;
uniform float fogDensityIn;
uniform vec4 renderColor;
uniform int addRenderFlags;

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;
uniform mat4 elementTransforms[31];

out vec2 uv;
out vec4 color;
out vec4 rgbaFog;
out float fogAmount;

#include vertexflagbits.ash
#include shadowcoords.vsh
#include fogandlight.vsh
#include vertexwarp.vsh

void main(void)
{
	vec4 worldPos = modelMatrix * elementTransforms[jointId] * vec4(vertexPositionIn, 1.0);
	
	worldPos = applyVertexWarping(flags | addRenderFlags, worldPos);
	
	vec4 cameraPos = viewMatrix * worldPos;
	
	uv = uvIn;
	color = renderColor * colorIn * applyLight(rgbaAmbientIn, rgbaLightIn, flags, cameraPos);
	rgbaFog = rgbaFogIn;
	
	
	gl_Position = projectionMatrix * cameraPos;
	calcShadowMapCoords(viewMatrix, worldPos);
	
	
	fogAmount = getFogLevel(worldPos, fogMinIn, fogDensityIn);
}