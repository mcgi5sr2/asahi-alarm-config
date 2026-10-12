// "Genie" — the window unfurls upward from a point at the bottom centre on
// open, and collapses back into it on close (macOS dock style). Restrained so
// it reads well at a ~150 ms duration. Warps the captured window via UV, like
// the bundled squash effect, and masks anything sampled outside the window.
vec4 animation(vec2 uv) {
    // p: 0 = collapsed into the point, 1 = full window. Reverses on close.
    float p = umbriel_direction > 0.0
        ? umbriel_clamped_progress
        : 1.0 - umbriel_clamped_progress;
    float e = p * p * (3.0 - 2.0 * p);            // smoothstep ease

    // Vertical unfurl: the window grows upward from the bottom edge (y = 1).
    // Map destination y back to a source y; the shown height fraction is e.
    float sy = 1.0 - (1.0 - uv.y) / max(e, 1e-3);

    // Horizontal neck: full width at the top, pinched at the bottom, opening up
    // as the animation progresses.
    float taper = mix(1.0, 0.12, clamp(sy, 0.0, 1.0));   // 1 top .. 0.12 bottom
    float neck = mix(taper, 1.0, e);
    float sx = (uv.x - 0.5) / max(neck, 1e-3) + 0.5;

    // Discard anything outside the window rectangle.
    float inside = step(0.0, sx) * step(sx, 1.0)
                 * step(0.0, sy) * step(sy, 1.0);

    return umbriel_sample(vec2(sx, sy)) * inside;
}
