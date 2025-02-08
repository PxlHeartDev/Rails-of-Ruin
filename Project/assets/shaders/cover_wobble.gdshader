shader_type canvas_item;

uniform sampler2D noise_texture: filter_linear;
uniform sampler2D noise_texture2: filter_linear;
uniform float speed = 0.005;

void fragment() {
	vec2 newUV = texture(noise_texture, mod(UV+TIME/32.0, 1.0)).rg;
	//COLOR = texture(noise_texture, mod(newUV+TIME/32.0, 1.0));
	
	vec2 noiseValue = vec2((texture(noise_texture, mod(SCREEN_UV + TIME * speed, 1.0)).r * 2.0) - 1.0, (texture(noise_texture2, mod(SCREEN_UV - TIME * speed/1.05, 1.0)).g * 2.0) - 1.0);
	COLOR += texture(TEXTURE, UV + noiseValue * 0.09);
}
