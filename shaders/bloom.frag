#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform sampler2D u_texture;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution.xy;
    
    vec4 sum = vec4(0.0);
    vec2 offset = 1.0 / u_resolution.xy;
    float spread = 3.0; // Bloom spread
    
    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec4 sampleCol = texture(u_texture, uv + vec2(x, y) * offset * spread);
            float brightness = max(max(sampleCol.r, sampleCol.g), sampleCol.b);
            if (brightness > 0.3) {
                // Boost bright colors
                sum += sampleCol * (brightness - 0.3) * 1.4;
            }
        }
    }
    
    vec4 bloom = sum / 25.0;
    vec4 col = texture(u_texture, uv);
    
    fragColor = col + bloom * 1.5;
}
