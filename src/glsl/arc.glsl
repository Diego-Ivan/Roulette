uniform vec4 arcColor;
uniform float angleDegrees;

void mainImage (out vec4 fragColor, in vec2 fragCoord, in vec2 resolution, in vec2 uv) {
  float x = 0.5 * cos(angleDegrees);
  float y = 0.5 * sin(angleDegrees);

  float angle = atan(x,y) * 1.0/3.14159265 * 0.5;
  float segment = step (fract(angle), angleDegrees);
  segment *= step (0.0, angle);

  fragColor = mix (arcColor, vec4(0.0,0.0,0.0,0.0), angle);
}