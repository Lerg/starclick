varying lowp vec2 var_texcoord0;
varying lowp float index;
varying lowp vec3 color;

lowp float rand(float i) {
	return fract(sin(dot(vec2(i, i), vec2(32.9898, 78.233))) * 43758.5453);
}

void main() {
	lowp float distance = length(var_texcoord0.xy - vec2(0.5, 0.5));
	lowp float alpha = 1.0;
	if (distance > 0.04) {
		alpha = pow(0.9 - distance, 10.0);
	}
	gl_FragColor = vec4(color, alpha);
}