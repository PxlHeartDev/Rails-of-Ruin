shader_type canvas_item;

uniform float sweepProg: hint_range(0.0, 2.0, 0.01) = 0.0;
uniform float pixelStrength = 32.0;
uniform sampler2D noiseTex;
uniform sampler2D noiseTex2;

void fragment() {
	vec2 newUV;
	newUV.x = round(UV.x*(1.0/pixelStrength)*(1.0/SCREEN_PIXEL_SIZE.x))/((1.0/pixelStrength)*(1.0/SCREEN_PIXEL_SIZE.x));
	newUV.y = round(UV.y*(1.0/pixelStrength)*(1.0/SCREEN_PIXEL_SIZE.y))/((1.0/pixelStrength)*(1.0/SCREEN_PIXEL_SIZE.y));
	if(sweepProg < 1.0) {
		COLOR.rgb = (texture(noiseTex, mod(newUV - TIME/10.0, 1)).rgb * 2.0 * texture(noiseTex2, mod(newUV + TIME/10.0, 1)).rgb) * COLOR.rgb;
		COLOR.a = 1.0 - (pow(2.0, pow(-5.0 * (1.3 - 1.6 * sweepProg - newUV.x), 2.0)) - 1.0) * (texture(noiseTex, newUV).r+0.01) * 3.0;
		if((1.3 - 1.6 * sweepProg) < newUV.x) {
			COLOR.a = 1.0;
		}
	} else {
		float newSweep = sweepProg - 1.0;
		COLOR.rgb = (texture(noiseTex, mod(newUV - TIME/10.0, 1)).rgb * 2.0 * texture(noiseTex2, mod(newUV + TIME/10.0, 1)).rgb) * COLOR.rgb;
		COLOR.a = 1.0 - (pow(2.0, pow(-5.0 * (1.3 - 1.6 * newSweep - newUV.x), 2.0)) - 1.0) * (texture(noiseTex, newUV).r+0.01) * 3.0;
		if((1.3 - 1.6 * newSweep) > newUV.x) {
			COLOR.a = 1.0;
		}
	}
}
