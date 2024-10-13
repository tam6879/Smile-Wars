shader_type spatial;

uniform sampler2D water_noise_normal;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable;
uniform vec3 water_color : source_color;
uniform float color_ratio = 0.25;
uniform float roughness = 0.25;
uniform float wave_height = 0.05;
uniform float wave_frequency = 5;
uniform float wave_speed = 0.5;
uniform float height_scale = 0.1;
uniform float height_frequency = 0.1;
uniform vec2 height_uv_scale = vec2(128, 128);

uniform vec2 uv_scale = vec2(32, 32);

uniform sampler2D sun_highlights;
uniform vec2 highlight_scale = vec2(1, 1);
uniform float highlight_speed = 1.0;

uniform vec2 chroma_r = vec2(0.1, 0.1);
uniform vec2 chroma_g = vec2(0.1, 0.1);
uniform vec2 chroma_b = vec2(0.1, 0.1);

uniform float alpha = 0.5;

vec3 soft_light(vec3 base, vec3 blend) {
	vec3 limit = step(0.5, blend);
	return mix(2.0 * base * blend + base * blend * (1.0 - 2.0 * blend),
		sqrt(base) * (2.0 * blend - 1.0) + (2.0 * base) * (1.0 - blend), limit);
}

void fragment() {
	vec2 t_uv = UV * uv_scale;
	vec2 t_suv = SCREEN_UV;

	float r = texture(sun_highlights, t_uv * highlight_scale + chroma_r + TIME * highlight_speed).r;
	float g = texture(sun_highlights, t_uv * highlight_scale + chroma_g + TIME * highlight_speed).g;
	float b = texture(sun_highlights, t_uv * highlight_scale + chroma_b + TIME * highlight_speed).b;

	t_uv.x += sin(TIME * wave_speed + (t_uv.x + t_uv.y) * wave_frequency) * wave_height;
	t_uv.y += cos(TIME * wave_speed + (t_uv.x - t_uv.y) * wave_frequency) * wave_height;

	t_suv.x += sin(TIME * wave_speed + (t_suv.x + t_suv.y) * wave_frequency * 0.5) * wave_height;
	t_suv.y += cos(TIME * wave_speed + (t_suv.x - t_suv.y) * wave_frequency * 0.5) * wave_height;
	vec3 blend = soft_light(texture(screen_texture, SCREEN_UV).rgb, vec3(r, g, b));
	NORMAL_MAP = texture(water_noise_normal, t_uv).rgb;
	ALBEDO = mix(blend, water_color, color_ratio);
	ROUGHNESS = roughness;
	ALPHA = alpha;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
