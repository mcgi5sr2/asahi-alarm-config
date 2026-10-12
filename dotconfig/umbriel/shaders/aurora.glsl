// "Aurora" border: a gradient of the palette colours (accent_primary,
// accent_secondary, warning, error) flowing slowly around the focused window's
// ring, with a gentle breathing shimmer and a soft bloom into the padding.
// Companion to the bundled "pulse" preset; both are pooled in config.toml.
vec4 border(vec2 uv) {
    // Distance in logical pixels out from the client rectangle (0 on the ring,
    // growing into the padding). Negative inside is clamped away.
    float d = max(umbriel_border_distance(uv), 0.0);

    vec4 native = umbriel_sample(uv);   // native ring pixels, premultiplied
    float ring = native.a;              // ring coverage

    // Angle around the window centre, normalised to 0..1 along the ring.
    float angle = atan(uv.y - 0.5, uv.x - 0.5);
    float base = angle / 6.28318530718 + 0.5;

    // Slow drift plus a wobble so the colour bands breathe rather than spin
    // uniformly. fract() keeps the palette lookup in range as it wraps.
    float flow = fract(base
                       + 0.03 * umbriel_time
                       + 0.06 * sin(base * 12.566 - umbriel_time * 0.6));

    // Blend across the wrapping palette; fall back to a cool blue with no palette.
    vec4 tint = umbriel_palette_count > 0
        ? umbriel_palette_at(flow)
        : vec4(0.40, 0.70, 1.0, 1.0);

    // Brightness shimmer travelling the other way for a subtle aurora flicker.
    float shimmer = 0.78 + 0.22 * sin(angle * 2.0 + umbriel_time * 1.1);

    // Bloom: strongest on the ring, fading across the padding.
    float glow = exp(-d / 16.0) * shimmer;

    return native * (1.0 - glow)
         + tint * glow * max(ring, 0.6 * exp(-d / 16.0));
}
