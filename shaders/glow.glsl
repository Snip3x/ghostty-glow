// Even glow for all coloured text. Uses the brightest channel (not luma),
// so blue/orange/red glow as much as green/white; only dark greys/black skip it.
const float STRENGTH  = 0.20;  // how much glow (0.2 subtle .. 0.6 strong)
const float SPREAD    = 1.7;   // px between samples; glow reaches ~R*SPREAD px
const float LOW       = 0.40;  // brightest-channel value where glow starts (dark greys stay unlit)
const float HIGH      = 0.65;  // full glow from here up
const int   R         = 8;     // grid radius -> (2R+1)^2 samples

float vmax(vec3 c) { return max(c.r, max(c.g, c.b)); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 px = 1.0 / iResolution.xy;
    vec2 uv = fragCoord * px;
    vec4 base = texture(iChannel0, uv);
    vec3 glow = vec3(0.0);
    float total = 0.0;
    float sigma = float(R) * 0.35;
    for (int y = -R; y <= R; y++) {
        for (int x = -R; x <= R; x++) {
            vec2 o = vec2(float(x), float(y));
            float w = exp(-dot(o, o) / (2.0 * sigma * sigma));
            vec4 s = texture(iChannel0, uv + o * SPREAD * px);
            float v = vmax(s.rgb);
            float on = smoothstep(LOW, HIGH, v) * s.a;
            // normalise so dimmer hues (blue, red) glow as strongly as bright ones
            glow += (s.rgb / max(v, 1e-3)) * on * w;
            total += w;
        }
    }
    glow = glow / total * STRENGTH;
    float around = 1.0 - smoothstep(0.35, 0.7, vmax(base.rgb));  // keep letters crisp
    vec3 add = glow * around;
    fragColor = vec4(base.rgb + add, clamp(base.a + vmax(add), 0.0, 1.0));
}
