#ifdef GL_ES
precision mediump float;
#endif

#define S(a,b,t) smoothstep(a, b, t)

// video here: https://www.youtube.com/watch?v=eKtsY7hYTPg&list=PLGmrMu-Iwbgs0H9va0DlopOGyYnlLmxhS

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

struct ray {
  vec3 o, d; // a ray has an origin and direction
};

ray CameraSetup(vec2 uv, vec3 camPos, vec3 lookAt, float zoom) {

  ray a;
  a.o = camPos;

  vec3 f = normalize(lookAt - camPos);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = a.o + f*zoom;
  vec3 i = c + uv.x*r + uv.y*u;

  a.d = normalize(i-a.o);

  return a;
}

vec3 closestPoint(ray r, vec3 p) {
  return r.o + max(0., dot(p-r.o, r.d))*r.d;
}

float distRay(ray r, vec3 p) {
  return length(p-closestPoint(r,p));
}

float bokeh(ray r, vec3 p, float size, float blur) {
  float d = distRay(r, p);
  size *= length(p);
  float c = S(size, size*(1.-blur), d);
  c*=mix(.6, 1., S(size*.8, size, d)); // add brighter outline
  return c;
}

vec3 streetLights(ray r, float t) {
  float side = step(r.d.x, 0.); // for alternating left and right lights
  // "fold" the screen to get lights on the other side for free
  r.d.x = abs(r.d.x);

  const float s = 1./10.;
  float m = 0.;

  for (float i=0.; i<1.; i+=s) {
    float ti= fract(t+i+side*s*.5);
    vec3 p = vec3(2.,2.,100.-ti*100.);
    m += bokeh(r, p, .03, .1) * ti * ti * ti;
  }
  return vec3(1., .7, .3)*m;
}

float N(float t) {
  return fract(sin(t*3456.) * 6547.);
}

vec3 headLights(ray r, float t) {

  float w1 = .25;
  float w2 = w1*1.2;

  const float s = 1./30.;
  float m = 0.;

  for (float i=0.; i<1.; i+=s) {

    float n = N(i);

    if (n>.1) continue;

    float ti= fract(t+i);
    float z = 100.-ti*100.;
    float fade = ti*ti*ti*ti*ti;
    float focus = S(.9, 1., ti);

    float size=mix(.05, .03, focus);

    m += bokeh(r, vec3(-1.-w1,.15, z), size, .1) * fade;
    m += bokeh(r, vec3(-1.+w1,.15, z), size, .1) * fade;

    m += bokeh(r, vec3(-1.-w2,.15, z), size, .1) * fade;
    m += bokeh(r, vec3(-1.+w2,.15, z), size, .1) * fade;

    float ref = 0.;
    ref += bokeh(r, vec3(-1.-w2,-.15, z), size*3., 1.) * fade;
    ref += bokeh(r, vec3(-1.+w2,-.15, z), size*3., 1.) * fade;

    m+=ref*focus;
  }
  return vec3(.9, .9, 1.)*m;
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  uv -= 0.5;
  uv.x *= u_resolution.x / u_resolution.y;

  //vec2 m = u_mouse.xy / u_resolution.xy;
  vec3 camPos = vec3(0., .2, 0.);
  vec3 lookAt = vec3(0., .2, 1.);

  ray r = CameraSetup(uv, camPos, lookAt, 2.);

  float t = u_time * .1;// + m.x;

  vec3 col = streetLights(r, t);
  col += headLights(r, t);
  gl_FragColor = vec4(col,1.);

}
