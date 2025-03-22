bool approxEqualTo(float val1, float val2, float leniency) {
	return ((val1 > val2 - leniency) && (val1 < val2 + leniency));
}

bool vec3ApproxEqualTo(vec3 vect1, vec3 vect2, float leniency) {
	return (
		approxEqualTo(vect1.r, vect2.r, leniency) &&
		approxEqualTo(vect1.g, vect2.g, leniency) &&
		approxEqualTo(vect1.b, vect2.b, leniency)
	);
}