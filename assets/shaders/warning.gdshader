shader_type canvas_item;

uniform bool edge_top = false;
uniform bool edge_bottom = false;
uniform bool edge_left = false;
uniform bool edge_right = false;

uniform bool corner_tl = false;
uniform bool corner_tr = false;
uniform bool corner_bl = false;
uniform bool corner_br = false;

uniform float flash_strength : hint_range(0.0, 1.0);
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

float edge_falloff(float dist, float edge) {
	return smoothstep(edge, 0.0, dist);
}

float bar(vec2 uv, vec2 origin, vec2 dir, float length, float thickness) {
	vec2 rel = uv - origin;
	float along = dot(rel, dir);
	float perp = dot(rel, vec2(-dir.y, dir.x));

	float inside_length = smoothstep(length, length - 0.02, along);
	float inside_thickness = smoothstep(thickness, 0.0, abs(perp));

	return inside_length * inside_thickness;
}

float corner_l(vec2 uv, vec2 corner_pos, vec2 dir_x, vec2 dir_y) {
	float bar_x = bar(uv, corner_pos, dir_x, 0.2, 0.1);
	float bar_y = bar(uv, corner_pos, dir_y, 0.2, 0.1);

	vec2 rel = uv - corner_pos;
	float curve = smoothstep(0.25, 0.0, length(rel));

	return max(bar_x, bar_y) * curve;
}

float blend_max(float a, float b, float k) {
	return log(exp(k * a) + exp(k * b)) / k;
}

void fragment() {
	vec2 uv = UV;
	float intensity = 0.0;
	float k = 16.0;

	if (edge_top) {
		intensity = blend_max(intensity, edge_falloff(uv.y, 0.1), k);
	}
	if (edge_bottom) {
		intensity = blend_max(intensity, edge_falloff(1.0 - uv.y, 0.1), k);
	}
	if (edge_left) {
		intensity = blend_max(intensity, edge_falloff(uv.x, 0.1), k);
	}
	if (edge_right) {
		intensity = blend_max(intensity, edge_falloff(1.0 - uv.x, 0.1), k);
	}

	if (corner_tl) {
		intensity = blend_max(intensity, corner_l(uv, vec2(0.0, 0.0), vec2(1.0, 0.0), vec2(0.0, 1.0)), k);
	}
	if (corner_tr) {
		intensity = blend_max(intensity, corner_l(uv, vec2(1.0, 0.0), vec2(-1.0, 0.0), vec2(0.0, 1.0)), k);
	}
	if (corner_bl) {
		intensity = blend_max(intensity, corner_l(uv, vec2(0.0, 1.0), vec2(1.0, 0.0), vec2(0.0, -1.0)), k);
	}
	if (corner_br) {
		intensity = blend_max(intensity, corner_l(uv, vec2(1.0, 1.0), vec2(-1.0, 0.0), vec2(0.0, -1.0)), k);
	}

	intensity = intensity * smoothstep(0.0, 0.15, intensity);
	
	COLOR = vec4(flash_color.rgb, flash_color.a * intensity * flash_strength);
}