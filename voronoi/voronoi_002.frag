#ifdef GL_ES
precision mediump float;
#endif

#define S(a,b,t) smoothstep(a, b, t)

// video here: https://www.youtube.com/watch?v=l-07BXzNdPw

uniform vec2 u_resolution;
uniform float u_time;

vec2 N22(vec2 p) {
  vec3 a = fract(p.xyx*vec3(123.34, 234.34, 345.65));
  a += dot(a, a+34.45);
  return fract(vec2(a.x*a.y, a.y*a.z));
}

void main() {

  vec2 uv = (2. * gl_FragCoord.xy - u_resolution.xy) / u_resolution.xy;

  float m = 0.;//N22(uv).x;
  float t = u_time * .4;

  float minDist = 1000.;
  float cellIndex = 0.;
  vec3 col = vec3(0.);

  if (false) {
    for (float i = 0.; i<20.; i++){
      vec2 n = N22(vec2(i));
      vec2 p = sin(n*t);
      float d = length(uv-p);
      m += S(.02, .01, d);

      if (d<minDist){
        minDist = d;
        cellIndex = i;
      }
    }
    col = vec3(minDist);

  } else {
    uv *= 3.;
    vec2 gv = fract(uv) - 0.5;
    vec2 id = floor(uv);
    vec2 cellId = vec2(0.);

    for (float y=-1.; y<=1.; y++){
      for (float x=-1.; x<=1.; x++){
        vec2 offset = vec2(x,y);
        vec2 n = N22(id+offset);
        vec2 p = offset + sin(n*t)*.5;
        float d = length(gv-p);
        if (d<minDist){
          minDist = d;
          cellId = id+offset;
        }
      }
    }
    col = vec3(minDist);
    //col.rg += cellId*.1;
  }

  //vec3 col = vec3(cellIndex/50.);
  //vec3 col = vec3(minDist);

  gl_FragColor = vec4(col,1.);

}
