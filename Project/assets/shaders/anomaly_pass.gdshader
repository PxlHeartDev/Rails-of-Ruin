shader_type canvas_item;

uniform float sweepProg = 0.0;
uniform sampler2D noiseTex;
uniform sampler2D noiseTex2;

void fragment() {
	if(sweepProg < 1.0) {
		COLOR.rgb = (texture(noiseTex, mod(UV - TIME/10.0, 1)).rgb * 2.0 * texture(noiseTex2, mod(UV + TIME/10.0, 1)).rgb) * COLOR.rgb;
		COLOR.a = 1.0 - (pow(2.0, pow(-5.0 * (1.3 - 1.6 * sweepProg - UV.x), 2.0)) - 1.0) * (texture(noiseTex, UV).r+0.01) * 3.0;
		if((1.3 - 1.6 * sweepProg) < UV.x) {
			COLOR.a = 1.0;
		}
	} else {
		float newSweep = sweepProg - 1.0;
		COLOR.rgb = (texture(noiseTex, mod(UV - TIME/10.0, 1)).rgb * 2.0 * texture(noiseTex2, mod(UV + TIME/10.0, 1)).rgb) * COLOR.rgb;
		COLOR.a = 1.0 - (pow(2.0, pow(-5.0 * (1.3 - 1.6 * newSweep - UV.x), 2.0)) - 1.0) * (texture(noiseTex, UV).r+0.01) * 3.0;
		if((1.3 - 1.6 * newSweep) > UV.x) {
			COLOR.a = 1.0;
		}
	}
}
