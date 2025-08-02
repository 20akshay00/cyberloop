shader_type canvas_item;

uniform sampler2D dissolve_texture : source_color;
uniform float dissolve_value : hint_range(0, 1);
uniform vec2 polygon_size;  // polygon bounding box size in local units

void fragment() {
    vec4 main_tex = texture(TEXTURE, UV);  // tiled main texture

    float noise = texture(dissolve_texture, fract(UV)).r;  // tile dissolve texture using fract(UV)
    main_tex.a *= step(dissolve_value, noise);

    COLOR = main_tex;
}


//void fragment() {
    //COLOR = vec4(UV, 0.0, 1.0); // adjust divisor for scale
//}
