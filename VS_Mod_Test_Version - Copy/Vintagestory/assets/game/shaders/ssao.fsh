#version 330 core

uniform sampler2D gPosition;
uniform sampler2D gNormal;
uniform sampler2D texNoise;
uniform vec3[64] samples;
uniform vec2 screenSize;
uniform sampler2D revealage;

in vec2 texcoord;
out vec4 outOcclusion;

#if SSAOLEVEL == 2
int kernelSize = 24;
float radius = 0.9;
#else
int kernelSize = 20;
float radius = 0.9;
#endif

float bias = 0.01;


uniform mat4 projection;

void main()
{
	float wboitatn = max(0, 1 - texture(revealage, texcoord).r) * 0.75;
	
	// tile noise texture over screen based on screen dimensions divided by noise size
	vec2 noiseScale = vec2(screenSize.x/8.0, screenSize.y/8.0); 

	vec4 texVal = texture(gPosition, texcoord); 
	
	vec3 fragPos = texVal.xyz;
	float attenuate = texVal.w + wboitatn;
	
	texVal = texture(gNormal, texcoord);
	vec3 normal = normalize(texVal.xyz);
	bool leavesHack = texVal.w > 0;
	
	// This seems to completely fix any distant ssao flickering artifacts while perservering everything else
	if (!leavesHack) {
		fragPos += normal * clamp(-fragPos.z/90 - 0.05, 0, 10);
	}


	float distanceFade = clamp(1.2 - (-fragPos.z) / 250, 0, 1);
	
	if (fragPos.x == 0 || distanceFade == 0) {
		outOcclusion = vec4(1);
		return;
	}
	
	vec3 randomVec = texture(texNoise, texcoord * noiseScale).xyz;
	
    vec3 tangent = normalize(randomVec - normal * dot(randomVec, normal));
    vec3 bitangent = cross(normal, tangent);
    mat3 TBN = mat3(tangent, bitangent, normal);
	
    float occlusion = 0.0;
		
    for( int i = 0; i < kernelSize; ++i)
    {
        vec3 sample = TBN * samples[i];
        sample = fragPos + sample * radius;

        vec4 offset = vec4(sample, 1.0);
        offset = projection * offset;
        offset.xyz /= offset.w;
        offset.xyz = offset.xyz * 0.5 + 0.5;
		
		offset.x = clamp(offset.x, texcoord.x - 0.04,  texcoord.x + 0.04);
		offset.y = clamp(offset.y, texcoord.y - 0.04,  texcoord.y + 0.04);

        float sampleDepth = texture(gPosition, offset.xy).z;
		float depthDiff = sampleDepth - (sample.z + bias);
		float rangeCheck = 0;
		
		if (leavesHack) {

			if (depthDiff >= 0.02 && depthDiff < 0.2 && abs(dot(texture(gNormal, offset.xy).rgb, normal) - 1) > 0.25) {
				rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));		
			}

		} else {
		
			if (depthDiff >= 0 && depthDiff < 0.2) {
				rangeCheck = smoothstep(0.0, 1.0, radius / abs(fragPos.z - sampleDepth));		
			}
			
		}
		
		occlusion += rangeCheck;
		
		
    }
	
	float occ = clamp(1.0 - min(1, occlusion / kernelSize * distanceFade) * (1-attenuate), 0, 1);
	
	
	// Some distant geometry gets overly dark, lets clamp the lower limit
	occ = max(occ, 0.67);
	
	
    outOcclusion = vec4(occ, occ, occ, 1);
}