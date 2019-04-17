#ifdef GL_ES
precision mediump float;
#endif

// simple 3D camera
// video here: https://www.youtube.com/watch?v=PBxuVlp7nuM

// forward vector = lookat - rayorigin
// right vector = y cross forward
// up vector = forward cross right

uniform vec2 u_resolution;
uniform float u_time;

float distLine(vec3 ro, vec3 rd, vec3 p){
  // get the perpendicular distance between a point in 3D space and a line
  return length(cross(p-ro, rd)) / length(rd);
}

float drawPoint(vec3 ro, vec3 rd, vec3 p){
  float d = distLine(ro, rd, p);
  d = smoothstep(.06, .05, d);
  return d;

}

void main() {

  float t = u_time;

  vec2 uv = gl_FragCoord.xy / u_resolution.xy; // 0 <> 1
  uv -= 0.5; // origin to centre of screen
  uv.x *= u_resolution.x / u_resolution.y; // account for non-square aspect ratio

  vec3 ro = vec3(3.*sin(t), 2., -3.*cos(t)); // ray origin (negative z is out of the screen)

  float zoom = 1.0;
  vec3 lookAt = vec3(.5); // centre of cube
  vec3 f = normalize(lookAt - ro);
  vec3 r = normalize(cross(vec3(0.,1.,0.), f)); // see youtube comment
  vec3 u = cross(f, r);

  // centre of screen = ro+forward * zoom
  vec3 c = ro + f * zoom;
  vec3 i = c + uv.x*r + uv.y*u;
  // ray direction is the intersection point minus starting point (ray origin)
  vec3 rd = i - ro;


  float d = 0.;

  // make a cube in space
  d+=drawPoint(ro, rd, vec3(0.,0.,0.));
  d+=drawPoint(ro, rd, vec3(0.,0.,1.));
  d+=drawPoint(ro, rd, vec3(0.,1.,0.));
  d+=drawPoint(ro, rd, vec3(0.,1.,1.));

  d+=drawPoint(ro, rd, vec3(1.,0.,0.));
  d+=drawPoint(ro, rd, vec3(1.,0.,1.));
  d+=drawPoint(ro, rd, vec3(1.,1.,0.));
  d+=drawPoint(ro, rd, vec3(1.,1.,1.));

  gl_FragColor = vec4(d);

}
