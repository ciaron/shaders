#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;

float Circle(vec2 uv, vec2 p, float r, float blur){
    float d = length(uv-p);
    float c = smoothstep(r, r-blur, d);
    return c;
}

void main() {

  vec2 uv = gl_FragCoord.xy / u_resolution.y;
  uv -= 0.5; //shorthand for coord -= vec2(.5, .5);
  uv.x *= u_resolution.x / u_resolution.y;

  float c = Circle(uv, vec2(.1, -.1), .4, .05);
  c -= Circle(uv, vec2(-.02, .05), .07, .01);
  c -= Circle(uv, vec2(.22, .05), .07, .01);

  float mouth = Circle(uv, vec2(.1, -.13), .3, .02);
  mouth -= Circle(uv, vec2(.1, -.03), .3, .02);

  c-=mouth;

  vec3 col = vec3(1., 1., 0.) * c ; //multiply by either 0 or 1 (or mask in step) - could call "c" "mask"
  gl_FragColor = vec4(col, 1.);

}
