shader_type canvas_item;
render_mode blend_mix;
#include "blend.gdshaderinc"

varying vec2 worldPos;

uniform sampler2D noise : source_color, repeat_enable;
uniform vec3 colour: source_color = vec3(0.607843, 0.960784, 0.960784);

void vertex() {
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	float tileSize = 2048.0;
	vec2 tileSizeVec = vec2(1.0/tileSize, 1.0/tileSize);

	vec2 newUV = worldPos*tileSizeVec;

	vec4 noiseTexture = texture(noise, newUV);

	COLOR.rgb = blendVec3(noiseTexture.xyz, COLOR.xyz*0.6);
	COLOR.rgb = blendVec3(COLOR.xyz, colour.xyz);
}
