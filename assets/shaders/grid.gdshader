shader_type canvas_item;

uniform vec2 resolution = vec2(1920.0, 1080.0);
uniform vec3 line_color: source_color = vec3(0.2, 0.3, 0.5);

uniform float zoom: hint_range(1.0, 50.0, 0.1) = 50.0;
uniform float rotation: hint_range(0.0, 6.28318, 0.01) = 0.0;
uniform vec2 translation = vec2(0., 0.);
uniform float skew_x_factor = 0.;
uniform float skew_y_factor = 0.;

uniform float thickness: hint_range(0.1, 10.0, 0.01) = 2.0;
uniform float brightness: hint_range(0.1, 4.0, 0.01) = 2.0;

float draw_grid(vec2 uv) {
	vec2 grid_uv = cos(uv * TAU);
	return max(grid_uv.x, grid_uv.y);
}

vec2 rotate(vec2 uv, float angle) {
	return uv * mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

vec2 skew_x(vec2 uv, float factor) {
	return uv * mat2(vec2(1, factor), vec2(0, 1));
}

vec2 skew_y(vec2 uv, float factor) {
	return uv * mat2(vec2(1, 0), vec2(factor, 1));
}

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= resolution.x / resolution.y;
	uv = rotate(uv, rotation) + translation * zoom;
	float line_thickness = zoom * thickness / resolution.y;
	vec3 color = smoothstep(1.0 - line_thickness, 1.0, draw_grid(uv * zoom)) * line_color;
	COLOR = vec4(color * brightness, 1.0);
}
