uniform vec4 arcColor;

void mainImage (out vec4 fragColor, in vec2 fragCoord, in vec2 resolution, in vec2 uv) {
  fragColor = arcColor;
}