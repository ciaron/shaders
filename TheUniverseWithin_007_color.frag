#ifdef GL_ES
precision mediump float;
#endif

#define S(a,b,t) smoothstep(a,b,t)

// tutorial video here: https://www.youtube.com/watch?v=3CycKKJiwis&feature=youtu.be

uniform vec2 u_resolution;
uniform vec2 u_mouse;
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

vec2 getPos(vec2 id, vec2 offset) {

  vec2 n = N22(id+offset) * u_time;
  return offset+sin(n)*.4;
}

// return distance from a point p to a line segment a-b
float distLine(vec2 p, vec2 a, vec2 b) {
  vec2 pa = p-a;
  vec2 ba = b-a;
  float t = clamp(dot(pa, ba)/dot(ba, ba), 0., 1.);
  return length(pa - ba*t);
}

// Draw a Line
float drawLine(vec2 p, vec2 a, vec2 b){
  float d = distLine(p,a,b); //get distance to line segment
  float d2 = length(a-b);
  float m = S(0.03, 0.01, d); // cut out thickness of line
  m *= S(1.2, .8, d2)*.5 + S(.05, .03, abs(d2-.75)); // fade longer lines, flash at certain lengths
  return m;
}

float layer(vec2 uv){
  float m = 0.;
  vec2 gv = fract(uv) -.5;
  vec2 id = floor(uv); // unique id for each pixel

  vec2 p[9];

  int i = 0;
  for (float y=-1.; y<=1.; y++){
    for (float x=-1.; x<=1.; x++){
      p[i++] = getPos(id, vec2(x,y)); // fails in WebGL based things, use glslViewer
      // the index of an array in a fragment shader has to be a constant or a loop index
      // Or unroll the loop
    }
  }

  float t = u_time * 10.;
  for (int i=0; i<9; i++) {
    m += drawLine(gv, p[4], p[i]);
    vec2 j = (p[i]-gv)*20.; // size of sparkle with multiplier
    float sparkle = 1./dot(j,j);
    m+=sparkle * (sin(t+fract(p[i]).x*10.)*.5 + .5); // fract removes artifact where sparkle is close to cell boundary
  }

  m += drawLine(gv, p[1], p[3]);
  m += drawLine(gv, p[1], p[5]);
  m += drawLine(gv, p[5], p[7]);
  m += drawLine(gv, p[7], p[3]);

  return m;

}

void main() {

  vec2 uv = (gl_FragCoord.xy - .5*u_resolution.xy) / u_resolution.y;
  vec2 mouse = (u_mouse.xy/u_resolution.xy) - .5;

  float gradient = uv.y;
  float m = 0.;
  float t = u_time * .1;;

  float s = sin(t);
  float c = cos(t);
  mat2 rot = mat2(c, -s, s, c);
  uv *= rot;
  mouse *= rot;


  // create layers with different sizes
  for (float i=0.; i<=1.; i+=1./4.){
    float z = fract(i+t);
    float size = mix(10., .5, z);

    // fade layers in and out
    float fade = S(0., .5, z) * S(1., .8, z);

    m += layer(uv*size + i*20. - mouse)*fade;
  }

  vec3 base = sin(t*5.*vec3(.345,.456,.657))*.3 + .6; // base color;
  vec3 col = m*base;
  col -= base*gradient;

  //col.rg = id*.2; // visualise id in each cell
  //if (gv.x>.48 || gv.y>.48) col = vec3(1,0,0);  // show grid for debugging

  gl_FragColor = vec4(col, 1.);

}
