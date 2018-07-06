#ifdef GL_ES
precision highp float;
#endif

varying vec2 vTextureCoord;
uniform sampler2D uSampler;
uniform float timeFactor;
uniform float Red;
uniform float Green;
uniform float Blue;

void main() {

    vec4 color = texture2D(uSampler, vTextureCoord);
    float colorFactor = abs(cos(timeFactor));

	color.r = colorFactor * Red + (1.0 - colorFactor) * color.r;
	color.g = colorFactor * Green + (1.0 - colorFactor) * color.g;
	color.b = colorFactor * Blue + (1.0 - colorFactor) * color.b;

	gl_FragColor = color;
}
