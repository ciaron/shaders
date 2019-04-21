#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

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

float remap01(float a, float b, float t){
    return (t-a) / (b-a);
}

float remap(float a, float b, float c, float d, float t) {
    return remap01(a, b, t) * (d-c) + c;
}


void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.y;
  uv -= 0.5; //shorthand for coord -= vec2(.5, .5);
  uv.x *= u_resolution.x / u_resolution.y;

  float mask =0.;

  //play with uv coords to change shape;
  //uv *= 1.1; // scale all
  //uv.y *= 11.; // scale y only

  float x = uv.x;
  float y = uv.y;

  //x += y*-.2; //skew
  //mask = Rect(vec2(x,y),  -.2, .2, -.3, .3, .01);

  // tapered rect:
  //mask = Rect(vec2(x,y),  -.2+y*.2, .2-y*.2, -.3, .3, .01);

  //float m = (x-.5)*(x+.5)*-1.;  //parabola through -.5, +.5
  //m *= 4.*m * -1.;

  float m = sin(u_time+x*8.) * .1;

  y += m;

  float blur = remap(-.5, .5, .01, .25, x);
  //blur *= blur;
  //blur = pow(blur*4., 1.5);
  mask = Rect(vec2(x,y),  -.5, .5, -.1, .1, blur);

  // original:
  //mask = Rect(vec2(x,y),  -.2, .2, -.3, .3, .01);

  vec3 col = vec3(1., 1., 1.) * mask;
  gl_FragColor = vec4(col, 1.);

}
