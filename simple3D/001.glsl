#ifdef GL_ES
precision mediump float;
#endif

// simple 3D
// video here: https://www.youtube.com/watch?v=dKA5ZVALOhs

uniform vec2 u_resolution;
uniform float u_time;

float distLine(vec3 ro, vec3 rd, vec3 p){
  return length(cross(p-ro, rd)) / length(rd);
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.xy; // 0 <> 1
  uv -= 0.5; // origin to centre of screen
  uv.x *= u_resolution.x / u_resolution.y; // account for non-square aspect ratio

  vec3 ro = vec3(0., 0., -2.); // ray origin (negative z is out of the screen)

  // ray direction is the intersection point minus starting point (ray origin)
  vec3 rd = vec3(uv.x, uv.y, 0.) - ro;

  float t = u_time;
  vec3 p = vec3(sin(t) ,0., 2. + cos(t)); // +ve depth
  float d = distLine(ro, rd, p);

  d = smoothstep(.1, .09, d);
  gl_FragColor = vec4(d);

}
