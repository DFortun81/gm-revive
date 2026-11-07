// jane_clap_fx();
// Thunder Clap (gm-revive overrides): Lady Jane slams the ground; a shockwave of dust and crackling light
// rolls out to the edge of its reach. (Was the old Thunder Clap object.)
////////////////////////////////////////////////////////////////////////////////////////////
var p, a, k, r;
r = _clap_range;
with(fx_make(1, x, y, 0, make_color_rgb(120, 100, 70), r / 10, 22)) { _squash = 0.45; _add = false; _alpha = 0.8; }
with(fx_make(1, x, y, 0, make_color_rgb(255, 240, 170), r / 13, 16)) { _squash = 0.45; _alpha = 0.9; }
with(fx_make(0, x, y, 4, make_color_rgb(255, 245, 200), 1.2, 10)) _grow = 2;
for(k = 0; k < 14; k += 1) {
    a = k * (360 / 14) + random(10);
    p = fx_make(0, x + lengthdir_x(12, a), y + lengthdir_y(6, a), 3, make_color_rgb(175, 155, 115), random_range(0.35, 0.55), 26);
    p._add = false; p._squash = 0.55; p._grow = 2; p._alpha = 0.65; p._vx = lengthdir_x(2.6, a); p._vy = lengthdir_y(1.3, a); p._drag = 0.92;
}
repeat(8) {
    a = random(360);
    p = fx_make(5, x + lengthdir_x(r * 0.8, a), y + lengthdir_y(r * 0.4, a), random_range(2, 14), make_color_rgb(255, 245, 170), 0.14, 10);
    p._x1 = x + lengthdir_x(r * 0.35, a + random_range(-20, 20)); p._y1 = y + lengthdir_y(r * 0.18, a); p._h1 = random_range(2, 18);
}
