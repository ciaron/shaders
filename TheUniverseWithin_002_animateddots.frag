#ifdef GL_ES
precision mediump float;
#endif

#define S(a,b,t) smoothstep(a,b,t)

// tutorial video here: https://www.youtube.com/watch?v=3CycKKJiwis&feature=youtu.be

uniform vec2 u_resolution;
uniform float u_time;

// Generate a "random" number
float N21(vec2 p) {
  p = fract(p*vec2(233.34, 851.73));
  p += dot(p, p+23.45);
  return fract(p.x*p.y);
}

vec2 N22(vec2 p) {
  float n = N21(p);
  return vec2(n, N21(p+n));
}

vec2 getPos(vec2 id) {

  //vec2 n = N22(id);
  //float x = sin(u_time*n.x);
  //float y = cos(u_time*n.y);
  //return vec2(x,y) * .4;

  // more concise:
  vec2 n = N22(id) * u_time;
  return sin(n)*.4;
}

// Draw a Line
// return distance from a point p to a line segment a-b
float distLine(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p-a;
  vec2 ba = b-a;
  float t = clamp(dot(pa, ba)/dot(ba, ba), 0., 1.);
  return length(pa - ba*t);
}

void main() {

  vec2 uv = (gl_FragCoord.xy - .5*u_resolution.xy) / u_resolution.y;

  //float d = distLine(uv, vec2(0.), vec2(1.));
  float m = 0.;

  uv *= 5.;
  vec2 gv = fract(uv) -.5;
  vec2 id = floor(uv); // unique id for each pixel

  vec2 p = getPos(id);
  float d = length(gv-p);
  m = S(.1, .05, d);
  vec3 col = vec3(m);

  //col.rg = id*.2; // visualise id in each cell
  if (gv.x>.48 || gv.y>.48) col = vec3(1,0,0);  // show grid for debugging

  gl_FragColor = vec4(col, 1.);

}
