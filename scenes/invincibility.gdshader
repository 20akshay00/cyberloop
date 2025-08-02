shader_type canvas_item;

uniform float overlay_strength : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 white_overlay = vec4(1.0, 1.0, 1.0, tex_color.a);
    COLOR = mix(tex_color, white_overlay, overlay_strength);
}
