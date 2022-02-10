#version 330 core

uniform vec2 frameSize;
uniform int isVertical;

out vec2 texCoords[21];

void main(void)
{
	float x = -1.0 + float((gl_VertexID & 1) << 2);
    float y = -1.0 + float((gl_VertexID & 2) << 1);
    gl_Position = vec4(x, y, 0, 1);
    vec2 texCoord = vec2((x+1.0) * 0.5, (y + 1.0) * 0.5);
	
	if (isVertical == 1) {
		float pixelSize = 1.0 / frameSize.y;
		
		for (int i = -8; i < 8; i++) {
			texCoords[i + 8] = texCoord + vec2(0, pixelSize * i);
		}

	} else {
		float pixelSize = 1.0 / frameSize.x;
		
		for (int i = -8; i < 8; i++) {
			texCoords[i + 8] = texCoord + vec2(pixelSize * i, 0);
		}
	}
}