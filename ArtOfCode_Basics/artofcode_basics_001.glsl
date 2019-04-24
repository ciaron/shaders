#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

void main() {

  vec2 coord = gl_FragCoord.xy / u_resolution.y;
  coord -= 0.5;
  coord.x *= u_resolution.x/u_resolution.y;

  float d = length(coord);
  float r = 0.3;

  //float c;
  //if (d<.3) c=1.; else c=0.;

  // smoothstep(a,b,x):
  //Interpolates smoothly from 0 to 1 based on x compared to a and b.

  //  1) Returns 0 if x < a < b or x > a > b
  //  2) Returns 1 if x < b < a or x > b > a
  //  3) Returns a value in the range [0,1] for the domain [a,b].
  // return a [0,1] interpolated if d in range [r, r-0.02]
  float c = smoothstep(r, r-0.02, d);

  gl_FragColor = vec4(vec3(c), 1.);

}
