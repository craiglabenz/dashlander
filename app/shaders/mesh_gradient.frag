#include <flutter/runtime_effect.glsl>

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_type;

out vec4 fragColor;

vec3 getBgColor1() { return vec3(0.12, 0.02, 0.2); } // Deep purple
vec3 getBgColor2() { return vec3(0.0, 0.15, 0.3); }  // Deep blue/teal
vec3 getBgColor3() { return vec3(0.2, 0.0, 0.1); }   // Deep magenta

vec3 getFgColor1() { return vec3(0.2, 0.05, 0.3); }  // Vibrant purple
vec3 getFgColor2() { return vec3(0.0, 0.3, 0.4); }   // Cyan/teal
vec3 getFgColor3() { return vec3(0.3, 0.0, 0.2); }   // Vibrant pink

void main() {
    vec2 uv = FlutterFragCoord().xy / u_resolution.xy;
    
    // Create slow, smooth movement
    float t = u_time * 0.2;
    
    // Position of color blobs
    vec2 pos1 = vec2(sin(t * 1.1) * 0.5 + 0.5, cos(t * 1.3) * 0.5 + 0.5);
    vec2 pos2 = vec2(sin(t * 1.4 + 2.0) * 0.5 + 0.5, cos(t * 1.2 + 1.0) * 0.5 + 0.5);
    vec2 pos3 = vec2(sin(t * 0.9 + 4.0) * 0.5 + 0.5, cos(t * 1.5 + 3.0) * 0.5 + 0.5);
    
    // Calculate distances
    float d1 = distance(uv, pos1);
    float d2 = distance(uv, pos2);
    float d3 = distance(uv, pos3);
    
    // Soft falloff
    float w1 = smoothstep(1.5, 0.0, d1);
    float w2 = smoothstep(1.5, 0.0, d2);
    float w3 = smoothstep(1.5, 0.0, d3);
    
    // Base colors based on type (0.0 = bg, 1.0 = fg)
    vec3 col1 = mix(getBgColor1(), getFgColor1(), u_type);
    vec3 col2 = mix(getBgColor2(), getFgColor2(), u_type);
    vec3 col3 = mix(getBgColor3(), getFgColor3(), u_type);
    
    // Base dark background
    vec3 baseCol = mix(vec3(0.01, 0.01, 0.02), vec3(0.03, 0.05, 0.08), u_type);
    
    // Blend colors based on weights
    vec3 finalColor = baseCol;
    finalColor = mix(finalColor, col1, w1 * 0.7);
    finalColor = mix(finalColor, col2, w2 * 0.7);
    finalColor = mix(finalColor, col3, w3 * 0.7);
    
    // Add some noise to prevent banding
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    finalColor += (noise - 0.5) * 0.03;
    
    fragColor = vec4(finalColor, 1.0);
}
