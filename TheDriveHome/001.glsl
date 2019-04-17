#ifdef GL_ES
precision mediump float;
#endif

#define S(a,b,t) smoothstep(a, b, t)

// video here: https://www.youtube.com/watch?v=eKtsY7hYTPg&list=PLGmrMu-Iwbgs0H9va0DlopOGyYnlLmxhS

uniform vec2 u_resolution;
uniform float u_time;

struct ray {
  vec3 o, d; // a ray has an origin and direction
};

ray getRay(vec2 uv, vec3 camPos, vec3 lookAt, float zoom) {

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
  float c = S(size, size*(1.-blur), d);
  c*=mix(.6, 1., S(size*.8, size, d)); // add brighter outline
  return c;
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  uv -= 0.5;
  uv.x *= u_resolution.x / u_resolution.y;

  vec3 camPos = vec3(0., .2, 0.);
  vec3 lookAt = vec3(0., .2, 1.);

  ray r = getRay(uv, camPos, lookAt, 2.);

  vec3 p = vec3(0.,0.,5.);

  float c = bokeh(r, p, .3, .1);
  vec3 col = vec3(1., .7, .3)*c;
  gl_FragColor = vec4(col,1.);

}
