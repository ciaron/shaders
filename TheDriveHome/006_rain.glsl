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


float N(float t) {
  return fract(sin(t*3456.) * 6547.);
}

vec4 N14(float t) {
  return fract(sin(t*vec4(123., 1024., 3456., 9564.)) * vec4(6547., 345., 8799., 1564.));
}

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

vec3 envLights(ray r, float t) {
  float side = step(r.d.x, 0.); // for alternating left and right lights

  r.d.x = abs(r.d.x);

  const float s = 1./10.;
  vec3 c = vec3(0.);

  for (float i=0.; i<1.; i+=s) {
    float ti= fract(t+i+side*s*.5);

    vec4 n = N14(i+side*100.);
    float fade = ti*ti*ti;
    float occlusion = sin(ti*6.28*10.*n.x)*0.5+0.5;
    fade = occlusion;
    float x = mix(2.5, 10., n.x);
    float y = mix(.1, 1.5, n.y);

    vec3 p = vec3(x, y, 50.-ti*50.);
    vec3 col = n.wzy;
    c += bokeh(r, p, .05, .1) * fade * col * .25;
  }
  return c;
}

vec3 headLights(ray r, float t) {

  float w1 = .25;
  float w2 = w1*1.2;

  t*=2.;  // oncoming cars go faster
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

vec3 tailLights(ray r, float t) {

  float w1 = .25;
  float w2 = w1*1.2;

  t *=.25;  //slower

  const float s = 1./15.;
  float m = 0.;

  for (float i=0.; i<1.; i+=s) {

    float n = N(i);  // 0 <> 1

    if (n>.5) continue;

    // n : 0 <> .5

    float lane = step(.25, n); // 0 or 1

    float ti= fract(t+i);
    float z = 100.-ti*100.;
    float fade = ti*ti*ti*ti*ti;
    float focus = S(.9, 1., ti);

    float size=mix(.05, .03, focus);
    float laneShift = S(1., .96, ti);
    float x = 1.5 - lane * laneShift;
    float blink = step(0., sin(t*1000.)) * 7. * lane * step(.96, ti);

    m += bokeh(r, vec3(x-w1, .15, z), size, .1) * fade;
    m += bokeh(r, vec3(x+w1, .15, z), size, .1) * fade;

    m += bokeh(r, vec3(x-w2, .15, z), size, .1) * fade;
    m += bokeh(r, vec3(x+w2, .15, z), size, .1) * fade * (1.+blink);

    float ref = 0.;
    ref += bokeh(r, vec3(x-w2, -.15, z), size*3., 1.) * fade;
    ref += bokeh(r, vec3(x+w2, -.15, z), size*3., 1.) * fade * (1.+blink*.1);

    m+=ref*focus;
  }
  return vec3(1., .1, .03)*m;
}

vec2 rain(vec2 uv, float t) {
  uv *= 3.;
  t *= 40.;

  vec2 a = vec2(3., 1.);      // scaling aspect ratio for mini boxes
  vec2 st = uv*a;
  vec2 id = floor(st); // generate an id for each box

  st.y+=t*.22;

  st.y += fract(sin(id.x*716.34) * 768.34); // use box id to generate vertical offset
  id = floor(st);
  st = fract(st) - .5; // make mini boxes, one for each raindrop

  t+=fract(sin(id.x*76.34 + id.y*143.7) * 768.34) * 6.28; // for speed

  float y = -sin(t + sin(t + sin(t) *.5)) * .43;
  vec2 p1 = vec2(0., y);
  float d = length((st-p1)/a);       // distance to centre of box
  float m1 = S(.07, 0., d);

  d = length( (fract(uv*a.x*vec2(1., 2.)) - .5) / vec2(1., 2.) );
  //d = length( (fract(uv*a.x) -.5));
  //float m2 = S(.3*(.5-st.y+.5), .0, d) * S(-.1, .1, st.y-p1.y);
  float m2 = S(.3*(.5-st.y), .0, d) * S(-.1, .1, st.y-p1.y);

  if (st.x>.46 || st.y > .49) m1 = 1.;

  return vec2(m1 + m2);
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.xy;
  uv -= 0.5;
  uv.x *= u_resolution.x / u_resolution.y;

  float t = u_time * .05;// + m.x;

  //vec2 m = u_mouse.xy / u_resolution.xy;
  vec3 camPos = vec3(.5, .2, 0.);
  vec3 lookAt = vec3(.5, .2, 1.);

  // distortion example
  //uv.x+=sin(uv.y * 40.) * .1;
  vec2 rainDistort = rain(uv, t);
  ray r = CameraSetup(uv+rainDistort, camPos, lookAt, 2.);

  vec3 col = streetLights(r, t);
  col += headLights(r, t);
  col += tailLights(r, t);
  col += envLights(r, t);

  col += (r.d.y + .25)* vec3(.2,.1,.5);

  col = vec3(rainDistort, 0.);
  gl_FragColor = vec4(col,1.);

}
