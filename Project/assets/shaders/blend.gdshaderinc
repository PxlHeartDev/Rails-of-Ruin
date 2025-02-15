float blend(float baseCol, float blendCol) {
	float finalColour;
	{
		if (baseCol < 0.5) {
			finalColour = 2.0 * baseCol * blendCol;
		} else {
			finalColour = 1.0 - 2.0 * (1.0 - blendCol) * (1.0 - baseCol);
		}
	}
	return finalColour;
}

vec3 blendVec3(vec3 baseCol, vec3 blendCol) {
	vec3 finalColour;
	finalColour.x = blend(baseCol.x, blendCol.x);
	finalColour.y = blend(baseCol.y, blendCol.y);
	finalColour.z = blend(baseCol.z, blendCol.z);
	return finalColour;
}