#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout(location = 0) in vec3 vertexPositionIn;
layout(location = 1) in vec2 uvIn;
// rgb = block light, a=sun light level
layout(location = 2) in vec4 rgbaLightIn;
layout(location = 3) in int renderFlagsIn;

uniform vec3 origin;
uniform mat4 mvpMatrix;

out vec2 uv;

#include vertexflagbits.ash
#include vertexwarp.vsh

void main(void)
{
	vec4 worldPos = vec4(vertexPositionIn + origin, 1.0);
	
	worldPos = applyVertexWarping(renderFlagsIn, worldPos);
	
	gl_Position = mvpMatrix * worldPos;
	
	uv = uvIn;
}