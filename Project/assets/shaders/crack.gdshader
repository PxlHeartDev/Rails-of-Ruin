shader_type canvas_item;
#include "approx.gdshaderinc"

uniform vec2 refractionOffset = vec2(16.0, -16.0);
uniform vec2 reflectionOffset = vec2(1.0, -1.0);
uniform vec4 reflectionColour: source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform sampler2D screen_texture: hint_screen_texture;

const vec4 WHITE = vec4(1.0);
const vec2 normalizedPixelSize = (1.0/vec2(1920.0, 1080.0));


void fragment() {
	// Current pixel colour in texture
	vec4 pixelColour = texture(TEXTURE, UV);
	// Colour of neighbouring pixel in texture
	vec4 nextColour = texture(TEXTURE, UV + TEXTURE_PIXEL_SIZE * reflectionOffset);
	// Colour of screen-space refraction effect
	vec4 refractionColour = texture(screen_texture, SCREEN_UV + SCREEN_PIXEL_SIZE * refractionOffset);
	// If the adjacent colour is transparent, use reflection, else use refraction
	vec4 colour = mix(reflectionColour, refractionColour, nextColour.a);
	// Now only display this shader if the current texture pixel is not transparent
	COLOR = colour * pixelColour.a;
}