// zio_empower_fx(rank);
// Zio grows stronger (gm-revive overrides): a flare of dark flame round him and a ring along the ground,
// bigger at rank 1 (rank 2 comes first, at half health; rank 1 at 10%).
////////////////////////////////////////////////////////////////////////////////////////////
var p, r, big;
r = argument0; big = 1 + (r == 1);
with(fx_make(1, x, y, 0, make_color_rgb(40, 0, 60), 2 * big, 26)) { _squash = 0.45; _add = false; _alpha = 0.8; }
with(fx_make(1, x, y, 0, make_color_rgb(170, 80, 255), 1.6 * big, 20)) _squash = 0.45;
repeat(10 * big) {
    p = fx_make(0, x + random_range(-14, 14), y, random(10), make_color_rgb(30, 0, 45), random_range(0.45, 0.7), 34);
    p._add = false; p._vh = random_range(1, 2.4); p._grow = 0.4; p._alpha = 0.85;
    p = fx_make(0, x + random_range(-10, 10), y, random(14), make_color_rgb(170, 70, 255), random_range(0.28, 0.4), 28);
    p._vh = random_range(1.2, 2.6); p._grow = 0.3;
}
