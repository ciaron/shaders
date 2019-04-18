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
  float d = distLine(p,a,b);
  float m = S(0.03, 0.01, d);
  m *= S(1.2, .8, length(a-b)); // fade longer lines
  return m;
}

void main() {

  vec2 uv = (gl_FragCoord.xy - .5*u_resolution.xy) / u_resolution.y;

  float m = 0.;

  uv *= 10.;
  vec2 gv = fract(uv) -.5;
  vec2 id = floor(uv); // unique id for each pixel

  vec2 p[9];
  int i = 0;
  for (float y=-1.; y<=1.; y++){
    for (float x=-1.; x<=1.; x++){
      p[i] = getPos(id, vec2(x,y));
      i++;
    }
  }

  float t = u_time * 10.;
  for (int i=0; i<9; i++) {
    m += drawLine(gv, p[4], p[i]);
    vec2 j = (p[i]-gv)*15.; // size of sparkle with multiplier
    float sparkle = 1./dot(j,j);
    m+=sparkle * (sin(t+p[i].x*10.)*.5 + .5);
  }

  m += drawLine(gv, p[1], p[3]);
  m += drawLine(gv, p[1], p[5]);
  m += drawLine(gv, p[5], p[7]);
  m += drawLine(gv, p[7], p[3]);

  vec3 col = vec3(m);

  //col.rg = id*.2; // visualise id in each cell
  //if (gv.x>.48 || gv.y>.48) col = vec3(1,0,0);  // show grid for debugging

  gl_FragColor = vec4(col, 1.);

}
