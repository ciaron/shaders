#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

float Circle(vec2 uv, vec2 p, float r, float blur){
    float d = length(uv-p);
    float c = smoothstep(r, r-blur, d);
    return c;
}

float Smiley(vec2 uv, vec2 p, float size) {
  uv -= p; //translate coordinate system
  uv /= size; // scale the coordinate system

  /// main circle
  float mask = Circle(uv, vec2(.1, -.1), .4, .03);

  // eyes
  mask -= Circle(uv, vec2(-.02, .05), .07, .01);
  mask -= Circle(uv, vec2(.22, .05), .07, .01);

  float mouth = Circle(uv, vec2(.1, -.13), .3, .02);
  mouth -= Circle(uv, vec2(.1, -.03), .3, .02);

  mask-=mouth;

  return mask;
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.y;
  uv -= 0.5; //shorthand for coord -= vec2(.5, .5);
  uv.x *= u_resolution.x / u_resolution.y;

  float mask = Smiley(uv, vec2(.0, .0), .4);
  vec3 col = vec3(1., 1., 0.) * mask ; //multiply by either 0 or 1 (or mask in step)
  gl_FragColor = vec4(col, 1.);

}
