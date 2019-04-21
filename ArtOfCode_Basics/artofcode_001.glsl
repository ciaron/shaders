#ifdef GL_ES
precision mediump float;
#endif

// video here: https://www.youtube.com/watch?v=cQXAbndD5CQ

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  // .5 centres coords (otherwise 0,0 is bottom left)
  vec2 coord = (gl_FragCoord.xy - .5*u_resolution) / u_resolution.y;
  //vec2 coord = (gl_FragCoord.xy - 0.09*u_resolution) / u_resolution.y;
  vec3 color = vec3(0.);
  // black =(0,0,0), white=(1,1,1), yellow=(1,1,0) cyan=0,1,1
  // magenta = 1,0,1
  //gl_FragColor = vec4(0., 0., 0., 1.);

  // make grid. fract reduces large number (x5) to fractional part
  vec2 gv = fract(coord * 5.) - .5;
  float d = length(gv); // length=distance from 0,0
  float m = smoothstep(.4, .3, d);

  color.rg = gv;
  color +=m;
  gl_FragColor = vec4(color, 1.);

}
