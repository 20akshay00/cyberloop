shader_type canvas_item;
uniform float freq = 5.;

uniform float lo;
uniform float hi;

void fragment() {
    float alpha = lo + (hi - lo) * (sin(freq * TIME) + 1.)/2.;
    COLOR.a = alpha;
}
