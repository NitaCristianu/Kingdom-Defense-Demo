shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec3 slime_color : source_color = vec3(1.0, 0.84, 0.0); // Gold color
uniform float metallic : hint_range(0.0, 1.0) = 0.8; // Slight metallic look
uniform float roughness : hint_range(0.0, 1.0) = 0.4; // Gooey surface
uniform float transparency : hint_range(0.0, 1.0) = 0.8; // Amount of transparency
uniform float refraction : hint_range(0.0, 1.0) = 0.1; // Fake refractive effect
uniform float wobble_intensity : hint_range(0.0, 1.0) = 0.01; // Wobble strength
uniform float wobble_speed : hint_range(0.0, 5.0) = 4.5; // Wobble speed

void vertex() {
    // Create a wobbling effect by modifying the vertex position
    float wobble = sin(TIME * wobble_speed + VERTEX.x * 5.0 + VERTEX.y * 5.0) * wobble_intensity;
    VERTEX += NORMAL * wobble;
}

void fragment() {
    // Base color with slime effect
    vec3 albedo = slime_color;

    // Apply transparency using ALPHA
    ALBEDO = albedo;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    ALPHA = transparency;

    // Fake refraction by distorting background
    vec2 screen_uv = SCREEN_UV;
    screen_uv += (NORMAL.xy * refraction) * 0.5;
    vec4 screen_tex = texture(SCREEN_TEXTURE, screen_uv);
    ALBEDO = mix(albedo, screen_tex.rgb, refraction);
	
    // Enable transparency
    ALPHA_SCISSOR_THRESHOLD = 0.1;
}
