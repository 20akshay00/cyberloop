shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0);
uniform bool reverse = false; // false: top-left to bottom-right, true: bottom-right to top-left

void fragment() {
    vec2 uv = UV;

    float sweep = reverse ? (1.0 - uv.x) + (1.0 - uv.y) * 0.3 : uv.x + uv.y * 0.3;
    float threshold = mix(0.0, 2.0, progress);

    if (sweep < threshold) {
        COLOR = COLOR;
    } else {
        COLOR.a = 0.0;
    }
}
