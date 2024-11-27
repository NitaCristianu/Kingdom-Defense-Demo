shader_type spatial;

uniform float scale = 10.;
uniform float speed;

float snoise(vec3 uv, float res)
{
    const vec3 s = vec3(1e0, 1e2, 1e3);
    uv *= res;
    
    vec3 uv0 = floor(mod(uv, res)) * s;
    vec3 uv1 = floor(mod(uv + vec3(1.0), res)) * s;
    
    vec3 f = fract(uv);
    f = f * f * (3.0 - 2.0 * f);

    vec4 v = vec4(uv0.x + uv0.y + uv0.z, uv1.x + uv0.y + uv0.z,
                  uv0.x + uv1.y + uv0.z, uv1.x + uv1.y + uv0.z);

    vec4 r = fract(sin(v * 1e-1) * 1e3);
    float r0 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);

    r = fract(sin((v + uv1.z - uv0.z) * 1e-1) * 1e3);
    float r1 = mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y);
    
    return mix(r0, r1, f.z) * 2.0 - 1.0;
}

vec3 cvtSpcPos(vec3 v, mat4 m) {
	return (m * vec4(v, 1.)).xyz;
}

vec3 cvtSpcDir(vec3 v, mat4 m) {
	return normalize((m * vec4(v, 0.0)).xyz);
}

float quadraticBezierFalloff(float t, float q, float p, float s) {
	return (q + 1. - t * (p - q)) + t * ((q + t * (s - q)) - q + 1. - t * (p - q));
}

void vertex(){
	VERTEX = cvtSpcPos(VERTEX,MODELVIEW_MATRIX) * 4.;
}

float  dist(vec2 a, vec2 b){
	return sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
}

void fragment() 
{
    vec2 fragCoord = UV.xy;
    
    vec2 p = -0.5 + fragCoord.xy;
    
    float color = 3.0 - (3.0 * length(2.0 * p));
    
    vec3 coord = vec3(atan(p.x, p.y) / 6.2832 + 0.5, length(p) * 0.4, 0.5);
    
	float t = TIME * speed;
    for (int i = 1; i <= 7; i++) 
    {
        float power = pow(2.0, float(i));
        color += (1.5 / power) * snoise(coord + vec3(0.0, -t * 0.05, t * 0.01), power * 16.0);
    }
	
	float al = max(color, 0.) * (-0.2-dist(fragCoord, vec2(.5,.5))* (min(snoise(coord, 1.), 1))) ;
    ALPHA = al;
	ALPHA = max(ALPHA, 0);
    ALBEDO = vec3(color *3., pow(max(color, 0.0), 2.0) * 0.4, pow(max(color, 0.0), 3.0) * 0.15) * 13.;
}
