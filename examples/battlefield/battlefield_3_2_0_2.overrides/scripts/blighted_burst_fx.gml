// blighted_burst_fx(range);
// A diseased unit bursts (gm-revive overrides; run as the dead unit): a spray of rot and gore over everyone
// within range, a ring of it along the ground, and a cloud of spores. (Was a flat lime disc.)
////////////////////////////////////////////////////////////////////////////////////////////
var r, p, a, s;
r = argument0;
with(fx_make(1, x, y, 2, make_color_rgb(80, 105, 20), r / 18, 26)) { _squash = 0.45; _add = false; _alpha = 0.7; }
with(fx_make(1, x, y, 2, make_color_rgb(190, 230, 70), r / 22, 20)) _squash = 0.45;
with(fx_make(0, x, y, sprite_height * 0.5, make_color_rgb(210, 240, 120), 1.2, 12)) _grow = 1.8;
repeat(16) {
    a = random(360); s = random_range(1.2, 3);
    p = fx_make(choose(0, 3), x, y, sprite_height * 0.5, choose(make_color_rgb(140, 180, 40), make_color_rgb(110, 30, 25), make_color_rgb(170, 200, 60)), random_range(0.15, 0.3), 26);
    p._add = false; p._vx = lengthdir_x(s, a); p._vy = lengthdir_y(s * 0.5, a); p._vh = random_range(0.8, 2.6); p._grav = 0.15;
    p._spin = random_range(-12, 12); p.image_angle = random(360);
}
repeat(6) {
    p = fx_make(0, x + random_range(-r / 2, r / 2), y + random_range(-r / 4, r / 4), random(10), make_color_rgb(110, 140, 30), random_range(0.4, 0.7), 40);
    p._add = false; p._vh = 0.3; p._grow = 1.6; p._alpha = 0.45;
}
