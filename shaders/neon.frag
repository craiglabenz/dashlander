#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;
uniform vec4 uColor;
uniform float uIntensity;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    vec4 texColor = texture(uTexture, uv);
    
    // Simple intensity multiplication for glow on existing alpha
    vec4 finalColor = texColor + (uColor * uIntensity * texColor.a);
    
    fragColor = finalColor;
}
