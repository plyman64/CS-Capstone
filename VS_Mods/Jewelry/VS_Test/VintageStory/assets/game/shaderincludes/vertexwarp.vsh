uniform float timeCounter;
uniform float windWaveCounter;
uniform float windWaveCounterHighFreq;
uniform float waterWaveCounter;
uniform float windSpeed;
uniform vec3 playerpos;
uniform float globalWarpIntensity;

uniform float glitchStrength = 0;
uniform float windWaveIntensity = 1;

uniform int perceptionEffectId = 1;
uniform float perceptionEffectIntensity = 1;



#include noise3d.ash



vec3 applyPerceptionWarping(vec3 worldPos) {
	
	if (perceptionEffectId == 2 && perceptionEffectIntensity > 0) { // Drunk
		float pci = perceptionEffectIntensity;
		float xf = (worldPos.x + playerpos.x) / 10;
		float zf = (worldPos.z + playerpos.z) / 10;
		worldPos.x += pci * gnoise(vec3(xf, zf, timeCounter/6)) / 2;
		worldPos.y += pci * gnoise(vec3(xf, zf, timeCounter/10)) / 2;
		worldPos.z += pci * gnoise(vec3(xf, zf, timeCounter/3.5)) / 2;
	}
	
	return worldPos;
}


vec4 applyLiquidWarping(bool windAffected, vec4 worldPos, float div) {
	#if WAVINGSTUFF == 1
	vec3 noisepos = vec3((worldPos.x + playerpos.x) / 3, (worldPos.z + playerpos.z) / 3, waterWaveCounter / 8 + (windAffected ? windWaveCounter / 6 : 0));
	worldPos.y += gnoise(noisepos) / div;
	
	worldPos.y += windWaveIntensity * gnoise(noisepos * 5) / (div * 4);
	
	worldPos.xyz = applyPerceptionWarping(worldPos.xyz);
	
	#endif
	
	return worldPos;
}

vec4 applyVertexWarping(int renderFlags, vec4 worldPos) {
	#if WAVINGSTUFF == 1
	
	if ((renderFlags & WindModeBitMask) > 0) {
		
		int windMode = (renderFlags >> WindModePostion) & 0xF;
		int windData =  (renderFlags >> WindDataPosition) & 0x7;
		
		float x = worldPos.x + playerpos.x;
		float z = worldPos.z + playerpos.z;
		
		if (windMode != 6) {
			float y = worldPos.y + playerpos.y;
			
			// Fixes jitter due to float rounding errors
			y = ceil(y * 10000) / 10000.0;
			
			float heightBend = 0;
			
			float strength = windWaveIntensity * (1 + windSpeed) / 30.0;
			float bendCounter = windWaveCounter;
			float vbendMul = 1/5.0;
			float wwaveHighFreq = windWaveCounterHighFreq;
			float strengthFactorY = 1;
			
			int windwaveConfig = 0;
			
			switch (windMode) {
				case 1: // Weak Wind
					strength = 0.005 + 0.015 * windSpeed;
					heightBend = (fract(y) + windData) / 7.0 * 1.3;
					break;
				case 2: // Normal wind
					strength = 0.005 + 0.015 * windSpeed;
					heightBend = (fract(y) + windData) / 4 * 1.3;
					break;
				case 3: // Leaves
					strength *= 0.5;
					heightBend = (fract(y) + windData) / 12.0 * 1.3;
					heightBend = heightBend / 2 + pow(heightBend, 1.5) / 2; // the pow makes the bend neatly rounded
					break;
				case 4: // Bend (for small stems)
					strength = 0;
					heightBend = (fract(y) + windData) / 7.0 * 1.3;
					break;
				case 5: // Tall Bend (for thick and/or tall stems)
					strength = 0;
					heightBend = (fract(y) + windData) / 14.0 * 1.3;
					heightBend = heightBend / 2 + pow(heightBend, 1.5) / 2; // the pow makes the bend neatly rounded
					vbendMul = 0.0;
					break;
				// case 6: Water
				case 7: // Extra Weak Wind
					strength = 0.01;
					heightBend = (fract(y) + windData) / 7.0 * 1.3;
					break;
				case 8: // Fruit
					strength *= 0.15;
					if (windData == 0) windData = -1;   // Slight fudge for very tall fruit such as pears
					y += (windData + 4) / 32.0;    // All vertices on the whole fruit should have the same y - or close to it - if windData was set correctly
					strengthFactorY = 3;
					break;
				case 9: // Weak Wind No Bend (for foliage with non bending stems)
					strength *= 0.2;
					heightBend = 0;
					break;
				case 10: // Weak Wind, Inverse Bend (for vines)
					strength *= 0.5;
					//strength = 0.02; // Not sure actually why this looks better and seems to scale just fine with the windspeed
					heightBend = ((1 - fract(y)) + windData) / 14.0 * 1.5;
					break;
			}
			
			
			// 1. Determine bend
			float bend = windSpeed * heightBend * windWaveIntensity;
			if (bend != 0)
			{
				float bendNoise = windSpeed * 0.2 + 1.4 * gnoise(vec3(mod(x, 4096.0) / 10, mod(z, 4096.0) / 10, mod(bendCounter, 1024.0) / 4));
				bend *= (0.8 + bendNoise);
				bend = min(4, bend);
			}
			
			// 2. Add more noise
			
			x += wwaveHighFreq;
			y += wwaveHighFreq;
			z += wwaveHighFreq;
			
			// 3. Generate wiggle from a set of curves
			// Visualized: http://fooplot.com/#W3sidHlwZSI6MCwiZXEiOiIyKnNpbih4LzgpK3Npbih4LzIpK3NpbigwLjUrMip4KStzaW4oMSszKngpIiwiY29sb3IiOiIjMDAwMDAwIn0seyJ0eXBlIjoxMDAwLCJ3aW5kb3ciOlsiLTI0Ljc5NTUzMjIyNjU2MjQ4NiIsIjI0Ljc5NTUzMjIyNjU2MjQ4NiIsIi0xNS4yNTg3ODkwNjI0OTk5OTEiLCIxNS4yNTg3ODkwNjI0OTk5OTEiXX1d
			worldPos.x += bend + strength * (2 * sin(x/2) + sin(x + y) + sin(0.5 + 4*x + 2*y) + sin(1 + 6*x + 3*y)/3);
			
			// This might need to be a new mode. It makes sunflower leaves nicely wiggly
			if (windMode == 1) worldPos.x += sin(x*20)*strength / 5.0 * windSpeed;
			
			worldPos.y += -bend * vbendMul + strength * strengthFactorY * (sin(5*y)/15 + cos(10*x/strengthFactorY) / 10 + sin(3*z/strengthFactorY)/2 + cos(x/strengthFactorY*2)/2.2);
			worldPos.z += strength * (2 * sin(z/4) + sin(z + 3 * y) + sin(0.5 + 4*z + 2*y) + sin(1 + 6*z + y)/3);
			
		}
		else {
			// Water wave
			vec3 noisepos = vec3(x / 3, z / 3, waterWaveCounter / 8 + windWaveCounter / 6);
			worldPos.y += gnoise(noisepos) / 10;
		}
	}
	
	
	
	if (glitchStrength > 0.1) {
		float str = max(0, glitchStrength - 0.1);
		str *= clamp(length(worldPos) * glitchStrength - 1, 0, 150);
		
		float xf = (worldPos.x + playerpos.x) / 10;
		float zf = (worldPos.z + playerpos.z) / 10;
		worldPos.x += str * gnoise(vec3(xf, zf, windWaveCounter/6)) / 5;
		worldPos.y += str * gnoise(vec3(xf, zf, windWaveCounter/10)) / 5;
		worldPos.z += str * gnoise(vec3(xf, zf, windWaveCounter/3.5)) / 5;
	}
	
	if (globalWarpIntensity > 0) {
		float x = max(0, (mod(20*windWaveCounter, 30)) + (worldPos.x + playerpos.x) / 5.0 + (worldPos.y + playerpos.y) / 8.0 - 40);
		worldPos.x += (sin(x / 2) + sin(0.5 + 2*x) + sin(1 + 3*x)/3) / 30.0 * globalWarpIntensity;
		worldPos.z += (cos(x / 3) + cos(0.2 + 2.2*x) + cos(1 + 4*x)/3) / 30.0 * globalWarpIntensity;
	}
	
	
	worldPos.xyz = applyPerceptionWarping(worldPos.xyz);
		
	#endif
		
	return worldPos;
}


