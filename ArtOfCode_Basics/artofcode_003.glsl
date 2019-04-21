#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

// 003 : animate

void main() {

  // .5 centres coords (otherwise 0,0 is bottom left)
  vec2 coord = (gl_FragCoord.xy - .5*u_resolution) / u_resolution.y;
  vec3 color = vec3(0.);
  float m = 0.;
  float t = u_time *2.;

  // make grid. fract reduces large number (x5) to fractional part
  vec2 gv = fract(coord * 5.) - .5;

  // double loop for neighbouring grid cells
  for (float y=-1.; y<=1.; y++) {
    for (float x=-1.; x<=1.; x++) {
      vec2 offs = vec2(x,y);
      // mix(.3,.5, 0.) = .3
      // mix(.3,.5, 1.) = .5
      // sin(t)*.5 +.5 makes sin(t) go from 0->1, not -1->1
      //float r = mix(.3, .5, sin(t));
      float r = mix(.3, .5, sin(t)*.5 + .5);

      float d = length(gv+offs);
      m+=smoothstep(r, r*.9, d);
    }
  }

  color.rg = gv;
  color +=m;
  gl_FragColor = vec4(color, 1.);

}
