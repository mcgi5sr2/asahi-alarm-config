// Aurora motion-smear cursor halo.
// While the pointer moves, soft aurora-coloured curtains appear around it and
// the content underneath (especially high-contrast text) ghosts in aurora
// colours as it slides past — reads like a chromatic smear. At rest the halo
// collapses to nothing (no box, no glow).
//
// Motion is read from umbriel_previous_sample_matrix: the previous-frame buffer
// is centred on the previous pointer position, so the transform re-aligning it
// to this frame encodes how far the pointer moved. The feedback also drives the
// colour-ghost "trail", which fades to zero at rest because the previous output
// then equals the screen.

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}

float vnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float s = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        s += a * vnoise(p);
        p *= 2.0;
        a *= 0.5;
    }
    return s;
}

// Green -> teal -> blue -> violet, wrapping back to green.
vec3 auroraRamp(float t) {
    vec3 c1 = vec3(0.10, 0.92, 0.45);
    vec3 c2 = vec3(0.10, 0.80, 0.78);
    vec3 c3 = vec3(0.26, 0.45, 0.96);
    vec3 c4 = vec3(0.62, 0.30, 0.95);
    float x = fract(t) * 4.0;
    if (x < 1.0)      return mix(c1, c2, x);
    else if (x < 2.0) return mix(c2, c3, x - 1.0);
    else if (x < 3.0) return mix(c3, c4, x - 2.0);
    else              return mix(c4, c1, x - 3.0);
}

vec4 cursor(vec2 uv) {
    vec4 base = umbriel_sample(uv);
    vec2 delta = uv - umbriel_pointer;
    float r = length(delta);
    float ang = atan(delta.y, delta.x);
    float t = umbriel_time;

    // --- Motion gate: 0 at rest, ~1 while moving (speed from feedback matrix) ---
    vec4 prev = umbriel_sample_previous(uv);
    vec2 mapped = (vec3(uv, 1.0) * umbriel_previous_sample_matrix).xy;
    float speed = clamp(length(mapped - uv), 0.0, 0.5);
    float motion = clamp(speed * 3000.0, 0.0, 1.0);

    // --- Aurora curtains ---
    vec2 np = vec2(ang * 1.6, r * 6.0 - t * 0.8);
    float curtain = fbm(np + 1.4 * fbm(np * 0.7 + vec2(0.0, t * 0.25)));
    curtain = pow(clamp(curtain, 0.0, 1.0), 1.6);
    float cpos = 0.12 * t + 0.6 * curtain + 0.10 * ang / 6.28318530718;
    vec3 col = auroraRamp(cpos);

    // Soft circular envelope, zero before the square edge.
    float env = exp(-r * r * 16.0);
    float edge = 1.0 - smoothstep(0.30, 0.46, r);
    float flicker = 0.55 + 0.45 * fbm(vec2(ang * 3.0, t * 1.4));
    float a = env * edge * curtain * flicker * 0.8 * motion;

    // Colour-ghost smear: tint the frame-to-frame change (text edges sliding
    // past) in aurora colours. Collapses to zero at rest (prev == screen).
    float trail = clamp(length(prev.rgb - base.rgb), 0.0, 1.0);
    a = clamp(a + 0.45 * trail * env * edge, 0.0, 1.0);

    return base * (1.0 - a) + vec4(col, 1.0) * a;
}
