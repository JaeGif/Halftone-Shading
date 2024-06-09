uniform vec3 uColor;
uniform vec2 uResolution;
uniform float uShadowRepetitions;
uniform vec3 uShadowColor;
uniform vec3 uLightColor;
uniform float uLightRepetitions;

varying vec3 vNormal;
varying vec3 vPosition;

#include ../includes/ambientLight.glsl;
#include ../includes/directionalLight.glsl;

vec3 halftone(
    vec3 color,
    float repetitions,
    vec3 direction,
    float low,
    float high,
    vec3 pointColor,
    vec3 normal
) {
    float intensity = dot(normal, direction); // currently from +1 -> -1
    // need to clamp and smooth
    intensity = smoothstep(low, high, intensity);

    vec2 uv = gl_FragCoord.xy / uResolution.y; // coordinates of render points
    uv *= repetitions; // num of vertical cells
    uv = mod(uv, 1.0);

    // inner circles
    float point = 1.0 - step(0.5 * intensity, distance(uv, vec2(0.5)));

    return mix(color, pointColor, point);
    

}

void main()
{
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = uColor;

    vec3 light = vec3(0.0);
    // params - lightColor, lightIntensity
    light += ambientLight(vec3(1.0), 1.0);
    light += directionalLight(
        vec3(1.0, 1.0, 1.0),    // lightColor
        1.0,                    // lightIntensity
        normal,                 // Normal
        vec3(1.0, 1.0, 1.0),    // lightPosition
        viewDirection,          // viewDirection
        1.0                     // specularPower
    );
    color *= light;

    // Halftone shadows
    color = halftone(
        color, 
        uShadowRepetitions, 
        vec3(0.0, -1.0, 0.0),
        - 0.8,
        1.5,
        uShadowColor,
        normal
    );
    // light 
    color = halftone(
        color, 
        uLightRepetitions, 
        vec3(1.0, 1.0, 0.0),
        0.5,
        1.5,
        uLightColor,
        normal
    );
   
    // drawing a circle
    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}