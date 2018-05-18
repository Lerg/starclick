uniform lowp vec4 params;

varying mediump vec2 var_texcoord0;
uniform mediump vec4 time;

void main() {
    bool is_cursor = params.x == 0.0;
    bool is_visible = params.y > 0.0;
    vec3 color = vec3(0.0, 1.0, 1.0);
    if (is_cursor) {
        color = vec3(0.0, 1.0, 0.0);
    }
    float alpha = 0.0;
    if (is_visible) {
        if (is_cursor) {
            alpha = 0.33;
        } else {
            alpha = 0.33 + sin(10.0 * time.x) / 6.0;
        }
    }
    gl_FragColor = vec4(color, alpha);
}
