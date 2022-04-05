#version 330 core
#extension GL_ARB_explicit_attrib_location: enable

layout(location = 0) in vec3 vertexPosition;

uniform mat4 projectionMatrix;
uniform mat4 modelMatrix;
uniform mat4 viewMatrix;

out vec3 texCoords;

#include vertexflagbits.ash
#include shadowcoords.vsh
#include fogandlight.vsh

void main () {
  texCoords = vertexPosition;
  vec4 worldPos = modelMatrix * vec4(vertexPosition, 1.0);
  
  gl_Position = projectionMatrix * viewMatrix * worldPos;
}