// marquis_bite_fx(unit);
// Marquis Elmdor's bite turns a unit (gm-revive overrides): blood streams from it to him and a dark red
// mist rises off it. (Was the old blood-dot particles.)
////////////////////////////////////////////////////////////////////////////////////////////
var u, p, k;
u = argument0;
if(!units_exists(u)) exit;
for(k = 0; k < 6; k += 1) {
    p = fx_make(5, x, y, sprite_height * 0.6, make_color_rgb(190, 15, 30), 0.18, 12 + k * 2);
    p._x1 = u.x + random_range(-4, 4); p._y1 = u.y; p._h1 = u.sprite_height * 0.6; p._add = false;
}
with(fx_make(0, u.x, u.y, u.sprite_height * 0.6, make_color_rgb(150, 0, 20), 0.8, 14)) { _add = false; _grow = 1.5; _alpha = 0.7; }
repeat(6) {
    p = fx_make(0, u.x + random_range(-8, 8), u.y, random(u.sprite_height), make_color_rgb(110, 0, 20), random_range(0.18, 0.3), 26);
    p._add = false; p._vh = random_range(0.4, 0.9); p._grow = 1.4; p._alpha = 0.7;
}
