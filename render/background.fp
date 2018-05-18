uniform lowp vec4 resolution;
uniform mediump vec4 time;

varying mediump vec2 noise_uv;
uniform lowp sampler2D noise_tex;

/*mediump float t = 0.0;
mediump float aspect = resolution.x / resolution.y;
mediump vec2 uv;
mediump vec2 pan;

mediump float rand(float i) {
	return fract(sin(dot(vec2(i, i), vec2(32.9898, 78.233))) * 43758.5453);
}

vec4 star(float i) {
	// p = initial_possition + pan * parallax
	mediump vec2 p = vec2(rand(10.0 * i), rand(i / 20.0)) + pan * (0.5 + rand(i) / 2.0);
	// Stretch position over the screen, plus small border so stars go smoothly off screen.
	p = mod(vec2(aspect, 1.0) * p, vec2(aspect + 0.05, 1.0 + 0.05)) - vec2(0.025, 0.025);
	mediump float distance = 4.0 * length(uv - p);
	return vec4(vec3(0.2 + rand(0.654 * i) / 5.0, 0.3 + rand(0.953 * i) / 2.0, 0.5 + rand(0.123 * i) / 2.0) * 0.003 * pow(distance, -1.1), 1);
}*/

void main() {
	/*t = time.x;
	uv = gl_FragCoord.xy / resolution.y;
	pan = vec2(-t / 15.0, -t / 20.0);*/

	mediump vec3 color1 = vec3(0.058, 0.058, 0.156);
	mediump vec3 color2 = vec3(0.423, 0.474, 0.690);
	if (gl_FragCoord.y / resolution.y > 0.5) {
		mediump vec3 tmp = color1;
		color1 = color2;
		color2 = tmp;
	}
	
	gl_FragColor = vec4(
		((color1 * (resolution.y - gl_FragCoord.y) + color2 * gl_FragCoord.y) / resolution.y) *
		(1.0 - 0.05 * texture2D(noise_tex, gl_FragCoord.xy / vec2(128.0, 128.0)).x), 1.0);

	/*for (int j = 0; j < 1; ++j) {
		gl_FragColor += star(float(j));
	}*/
}