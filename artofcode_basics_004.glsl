#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

// Rectangles
float Band(float t, float start, float end, float blur) {

  float step1 = smoothstep(start-blur, start+blur, t);
  float step2 = smoothstep(end+blur, end-blur, t);
  return step1*step2;
}

float Rect(vec2 uv, float left, float right, float top, float bottom, float blur) {
    float band1 = Band(uv.x, left, right, blur);
    float band2 = Band(uv.y, top, bottom, blur);
    return band1 * band2;
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.y;
  uv -= 0.5; //shorthand for coord -= vec2(.5, .5);
  uv.x *= u_resolution.x / u_resolution.y;

  float mask =0.;
  mask = Rect(uv,  -.2, .2, -.3, .3, .01);

  vec3 col = vec3(1., 1., 1.) * mask;
  gl_FragColor = vec4(col, 1.);

}
