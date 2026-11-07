// vanish_fx();
// A Rogue vanishes (gm-revive overrides): a burst of smoke that hangs and drifts where it stood.
////////////////////////////////////////////////////////////////////////////////////////////
var p, a;
with(fx_make(0, x, y, sprite_height * 0.5, make_color_rgb(40, 40, 50), 1.2, 30)) { _add = false; _grow = 1.6; _alpha = 0.75; }
repeat(12) {
    a = random(360);
    p = fx_make(0, x, y, random(sprite_height), choose(make_color_rgb(60, 60, 70), make_color_rgb(110, 110, 120), make_color_rgb(30, 30, 35)), random_range(0.4, 0.7), 40);
    p._add = false; p._grow = 1.8; p._alpha = 0.7; p._vx = lengthdir_x(0.9, a); p._vy = lengthdir_y(0.45, a); p._vh = random_range(0.1, 0.5); p._drag = 0.94;
}
