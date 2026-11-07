// brood_hatch_fx(x, y);
// A broodling bursts out of the ground (gm-revive overrides): shards of eggshell, a splash of ooze and a
// ring of earth thrown up. (Was a small orange pulse.)
////////////////////////////////////////////////////////////////////////////////////////////
var hx, hy, p;
hx = argument0; hy = argument1;
with(fx_make(1, hx, hy, 0, make_color_rgb(110, 80, 50), 1.6, 18)) { _squash = 0.45; _add = false; _alpha = 0.7; }
with(fx_make(0, hx, hy, 10, make_color_rgb(240, 200, 150), 0.7, 10)) _grow = 1.6;
repeat(8) {
    p = fx_make(3, hx, hy, 12, choose(make_color_rgb(240, 200, 190), make_color_rgb(200, 90, 90), make_color_rgb(250, 235, 220)), random_range(0.25, 0.4), 22);
    p._add = false; p._vx = random_range(-1.8, 1.8); p._vy = random_range(-0.8, 0.8); p._vh = random_range(1, 2.6); p._grav = 0.16;
    p._spin = random_range(-15, 15); p.image_angle = random(360);
}
repeat(5) {
    p = fx_make(0, hx, hy, 10, make_color_rgb(170, 200, 60), 0.13, 22);
    p._add = false; p._vx = random_range(-1.2, 1.2); p._vh = random_range(0.6, 1.8); p._grav = 0.15; p._grow = 0.7;
}
