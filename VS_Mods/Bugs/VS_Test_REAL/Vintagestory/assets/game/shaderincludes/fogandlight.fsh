uniform float flatFogDensity;
uniform float flatFogStart;
uniform float viewDistance;
uniform float viewDistanceLod0;
uniform float zNear = 0.3;
uniform float zFar = 1500.0;
uniform vec3 lightPosition;
uniform float shadowIntensity = 1;

#if SHADOWQUALITY > 0
in float blockBrightness;
in vec4 shadowCoordsFar;
uniform sampler2DShadow shadowMapFar;
uniform float shadowMapWidthInv;
uniform float shadowMapHeightInv;
#endif

#if SHADOWQUALITY > 1
in vec4 shadowCoordsNear;
uniform sampler2DShadow shadowMapNear;
#endif


float linearDepth(float depthSample)
{
    depthSample = 2.0 * depthSample - 1.0;
    float zLinear = 2.0 * zNear / (zFar + zNear - depthSample * (zFar - zNear));
    return zLinear;
}

vec4 applyFog(vec4 rgbaPixel, float fogWeight) {
	return vec4(mix(rgbaPixel.rgb, rgbaFog.rgb, fogWeight), rgbaPixel.a);
}


float getBrightnessFromShadowMap() {
	#if SHADOWQUALITY > 0
	float totalFar = 0.0;
	if (shadowCoordsFar.z < 0.999 && shadowCoordsFar.w > 0) {
		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				float inlight = texture (shadowMapFar, vec3(shadowCoordsFar.xy + vec2(x * shadowMapWidthInv, y * shadowMapHeightInv), shadowCoordsFar.z - 0.0009));
				totalFar += 1 - inlight;
			}
		}
	}
	totalFar /= 9.0;

	
	float b = 1.0 - shadowIntensity * totalFar * shadowCoordsFar.w * 0.5;
	#endif
	
	
	#if SHADOWQUALITY > 1
	float totalNear = 0.0;
	if (shadowCoordsNear.z < 0.999 && shadowCoordsNear.w > 0) {
		for (int x = -1; x <= 1; x++) {
			for (int y = -1; y <= 1; y++) {
				float inlight = texture (shadowMapNear, vec3(shadowCoordsNear.xy + vec2(x * shadowMapWidthInv, y * shadowMapHeightInv), shadowCoordsNear.z - 0.0005));
				totalNear += 1 - inlight;
			}
		}
	}
	
	totalNear /= 9.0;
	
	

	
	b -=  shadowIntensity * totalNear * shadowCoordsNear.w * 0.5;
	#endif
	
	#if SHADOWQUALITY > 0
	b = clamp(b + blockBrightness, 0, 1);
	return b;
	#endif
	
	return 1.0;
}


float getBrightnessFromNormal(vec3 normal, float normalShadeIntensity, float minNormalShade) {

	// Option 2: Completely hides peter panning, but makes semi sunfacing block sides pretty dark
	float nb = max(minNormalShade, 0.5 + 0.5 * dot(normal, lightPosition));
	
	// Let's also define that diffuse light from the sky provides an additional brightness boost for up facing stuff
	// because the top side of blocks being darker than the sides is uncanny o__O
	nb = max(nb, dot(normalize(normal), vec3(0, 1, 0)) * 0.95);
	
	return mix(1, nb, normalShadeIntensity);
}



vec4 applyFogAndShadow(vec4 rgbaPixel, float fogWeight) {
	float b = getBrightnessFromShadowMap();
	rgbaPixel *= vec4(b, b, b, 1);
	
	return applyFog(rgbaPixel, fogWeight);
}

vec4 applyFogAndShadowWithNormal(vec4 rgbaPixel, float fogWeight, vec3 normal, float normalShadeIntensity, float minNormalShade) {
	float b = getBrightnessFromShadowMap();
	float nb = getBrightnessFromNormal(normal, normalShadeIntensity, minNormalShade);
		
	b = min(b, nb);
	rgbaPixel *= vec4(b, b, b, 1);
	
	return applyFog(rgbaPixel, fogWeight);
}



float getFogLevel(float fogMin, float fogDensity, float worldPosY) {
	float depth = gl_FragCoord.z;	
	float clampedDepth = min(250, depth);
	float heightDiff = worldPosY - flatFogStart;
	
	//float extraDistanceFog = max(-flatFogDensity * flatFogStart / (160 + heightDiff * 3), 0);   // heightDiff*3 seems to fix distant mountains being supper fogged on most flat fog values
	// ^ this breaks stuff. Also doesn't seem to be needed? Seems to work fine without
	
	float extraDistanceFog = max(-flatFogDensity * clampedDepth * (flatFogStart) / 60, 0); // div 60 was 160 before, at 160 thick flat fog looks broken when looking at trees

	float distanceFog = 1 - 1 / exp(clampedDepth * (fogDensity + extraDistanceFog));
	float flatFog = 1 - 1 / exp(heightDiff * flatFogDensity);
	
	float val = max(flatFog, distanceFog);
	float nearnessToPlayer = clamp((8-depth)/16, 0, 0.8);
	val = max(min(0.04, val), val - nearnessToPlayer);
	
	// Needs to be added after so that underwater fog still gets applied. 
	val += fogMin; 
	
	return clamp(val, 0, 1);
}