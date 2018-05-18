uniform lowp vec4 params;

varying mediump vec2 var_texcoord0;
uniform mediump vec4 time;

void main() {
	float ratio = params.x;
	vec3 color_good = vec3(0.0, 1.0, 0.0);
	vec3 color_bad = vec3(1.0, 0.0, 0.0);

	float alpha = 0.8;
	if (var_texcoord0.x < ratio) {
		gl_FragColor = vec4(color_good, alpha);
	} else {
		gl_FragColor = vec4(color_bad, alpha);
	}
}