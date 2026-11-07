// zio_blackwave_fx(x, y, h, unit, supreme);
// Black Wave lands (gm-revive overrides): a dark bolt from (x, y, height h) to the unit, and at the unit a
// dark ring collapsing inward with shadow wisps rising off it. Supreme Black Wave (supreme = true) is a
// heavy pillar from the sky instead, with a shockwave and shards.
////////////////////////////////////////////////////////////////////////////////////////////
var u, b, p, hh, big;
u = argument3; big = argument4;
if(!instance_exists(u)) exit;
hh = u.sprite_height * 0.5;
if(!big) {
    b = instance_create(u.x, u.y, obj_fx_bolt);
    b._x1 = argument0; b._y1 = argument1; b._h1 = argument2;
    b._x2 = u.x; b._y2 = u.y; b._h2 = hh;
}
else {
    b = instance_create(u.x, u.y, obj_fx_bolt);
    b._x1 = u.x; b._y1 = u.y; b._h1 = u.y + 40;
    b._x2 = u.x; b._y2 = u.y; b._h2 = 0;
    b._w = 2.6; b._jag = 4; b._n = 14; b._maxlife = 26;
    with(fx_make(1, u.x, u.y, 0, make_color_rgb(60, 0, 90), 3.2, 24)) { _squash = 0.45; _add = false; _alpha = 0.8; }
    with(fx_make(1, u.x, u.y, 0, make_color_rgb(180, 90, 255), 2.4, 18)) _squash = 0.45;
    repeat(16) {
        p = fx_make(3, u.x, u.y, random(hh * 2), make_color_rgb(110, 40, 170), random_range(0.35, 0.55), 26);
        p._vx = random_range(-2.6, 2.6); p._vy = random_range(-1.2, 1.2); p._vh = random_range(1, 3.5); p._grav = 0.15;
        p._spin = random_range(-15, 15); p.image_angle = random(360); p._add = false;
    }
}
with(fx_make(8, u.x, u.y, hh, make_color_rgb(150, 60, 230), 1.5 + big, 16)) _squash = 1;
with(fx_make(0, u.x, u.y, hh, make_color_rgb(25, 0, 40), 0.9 + big * 0.6, 18)) { _add = false; _grow = 0.4; _alpha = 0.8; }
repeat(6 + big * 6) {
    p = fx_make(0, u.x + random_range(-9, 9), u.y, random_range(4, hh * 1.6), make_color_rgb(25, 8, 40), random_range(0.25, 0.4), 26);
    p._add = false; p._vh = random_range(0.4, 1); p._grow = 1.8; p._alpha = 0.75;
}
