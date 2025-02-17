#include <flutter/runtime_effect.glsl>

uniform vec2 u_size;          // Screen or texture size
uniform float u_pixel_size;   // The pixelation block size
uniform sampler2D u_texture_input;

out vec4 frag_color;

void main() {
    vec2 uv = FlutterFragCoord().xy / u_size; // Normalize coordinates

    // Calculate the pixelated UV by snapping to the grid
    vec2 pixelated_uv = floor(uv * u_size / u_pixel_size) * u_pixel_size / u_size;

    // Sample the texture using the pixelated coordinates
    frag_color = texture(u_texture_input, pixelated_uv);
}
