#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout(location = 0) in vec3 vertexPositionIn;
layout(location = 1) in vec2 uvIn;
layout(location = 2) in vec4 colorIn;
layout(location = 3) in int flags;
layout(location = 4) in int jointId;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat4 elementTransforms[31];
uniform int addRenderFlags;

out vec2 uv;

void main(void)
{
	vec4 cameraPos = modelViewMatrix * elementTransforms[jointId] * vec4(vertexPositionIn, 1.0);
	uv = uvIn;
	gl_Position = projectionMatrix * cameraPos;
}