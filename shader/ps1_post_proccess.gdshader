shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec3 screen_color = texture(screen_texture, UV).rgb;
	vec3 quantized_color = floor((screen_color * 255.0) / 8.0) / 31.0;
	
	COLOR = vec4(quantized_color,1);
}