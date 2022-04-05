uniform vec4 colorMapRects[20];
uniform float seasonRel;
uniform float seaLevel;
uniform float atlasHeight;
uniform float seasonTemperature;

out vec2 climateColorMapUv;
out vec2 seasonColorMapUv;

out float seasonWeight;
out float heretemp;
out float frostAlpha;



float cmod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 cmod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return cmod289(((x * 34.0) + 1.0) * x);}

float valuenoise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}




void calcColorMapUvs(int colormapData, vec4 worldPos, float sunlightLevel, bool isLeaves) {
	int seasonMapIndex = colormapData & 0x3f;
	int climateMapIndex = (colormapData >> 8) & 0xf;
	int frostableBit = (colormapData >> 12) & 1;
	float tempRel = clamp(((colormapData >> 16) & 0xff) / 255.0, 0.001, 0.999);
	float rainfallRel = clamp(((colormapData >> 24) & 0xff) / 255.0, 0.001, 0.999);
	
	frostAlpha=0;
	heretemp = tempRel + seasonTemperature;
	if (frostableBit > 0 && heretemp < 0.333) {
		frostAlpha = (valuenoise(worldPos.xyz / 2) + valuenoise(worldPos.xyz * 2)) * 1.25 - 0.5;
		frostAlpha -= max(0, 1 - pow(2*sunlightLevel, 10));
	}
	
	if (climateMapIndex > 0) {
	#if RADEONHDFIX == 1
		// I have no idea why this is needed for Radeon HD 5000/6000 series cards. 
		vec4 rect = colorMapRects[climateMapIndex];
	#else
		vec4 rect = colorMapRects[climateMapIndex - 1];
	#endif
		climateColorMapUv = vec2(
			rect.x + rect.z * tempRel,
			rect.y + rect.w * rainfallRel 
		);
	} else {
		climateColorMapUv = vec2(-1,-1);
	}
	
	if (seasonMapIndex > 0) {
		vec4 rect = colorMapRects[seasonMapIndex - 1];
		
		float noise;
		
		if (isLeaves) {
			noise = (valuenoise(worldPos.xyz / 6) + valuenoise(worldPos.xyz / 2) - 0.55) * 1.25;
		} else {
			noise = (valuenoise(worldPos.xyz / 24) + valuenoise(worldPos.xyz / 12) - 0.55) * 1.25;
		}
		
		float b = valuenoise(worldPos.xyz) + valuenoise(worldPos.xyz/2);
		
		seasonColorMapUv = vec2(
			rect.x + rect.z * clamp(seasonRel + b/40, 0.01, 0.99),
			rect.y + rect.w * clamp(noise, 0.5 / (rect.w * atlasHeight), 15.5 / (rect.w * atlasHeight))
		);
		
			
		// different seasonWeight for tropical seasonTints - rich greens based on varying rainfall, but turn this off (anaemic / dying appearance) in colder areas
		if ((colormapData & 0xc0) == 0x40)
		{
			seasonWeight = 1;
			// 0.5 - cos(x/42.0)/2.3
			// http://fooplot.com/#W3sidHlwZSI6MCwiZXEiOiIwLjUtY29zKHgvNDIuMCkvMi4zIiwiY29sb3IiOiIjMDAwMDAwIn0seyJ0eXBlIjoxMDAwLCJ3aW5kb3ciOlsiMCIsIjI1NSIsIjAiLCIxIl19XQ--   
		
			// we dial this down to nothing (leaving dead-looking climate tinted foliage only) if the temperature is below around 0 degrees, browning starts below around 20 degrees
			seasonWeight = clamp((tempRel + seasonTemperature / 2) * 0.9 - 0.1, 0, 1) * clamp(2 * (0.5 - cos(rainfallRel * 255.0 / 42.0)) / 2.1, 0.1, 0.75);
		} else {

			// Lets use temperature and also make it so that cold areas are also more affected by seasons
			// http://fooplot.com/#W3sidHlwZSI6MCwiZXEiOiIwLjUtY29zKHgvNDIuMCkvMi4zK21heCgwLDEyOC14KS8yNTYvMi1tYXgoMCx4LTEzMCkvMjAwIiwiY29sb3IiOiIjMDAwMDAwIn0seyJ0eXBlIjoxMDAwLCJ3aW5kb3ciOlsiMCIsIjI1NSIsIjAiLCIxIl19XQ--
	
			// We need ground level temperature (i.e. reversing the seaLevel adjustment in ClientWorldMap.GetAdjustedTemperature()). This formula is shamelessly copied from TerraGenConfig.cs
			float x = tempRel * 255;
			float seaLevelDist = worldPos.y - seaLevel;
			x += max(0, seaLevelDist * 1.5);

			seasonWeight = clamp(0.5 - cos(x / 42.0) / 2.3 + max(0, 128 - x) / 256 / 2 - max(0,x - 130)/200, 0, 1);
		}
		
	} else {
		seasonColorMapUv = vec2(-1,-1);
	}
}