// stitch_hateful_fx(unit);
// Hateful Strike lands (gm-revive overrides): a great rusty cleaver slash across the unit, a heavy
// impact, and bile spattering off it. (Was the old Heroic Strike sprite.)
////////////////////////////////////////////////////////////////////////////////////////////
var u, p, hh, a;
u = argument0;
if(!units_exists(u)) exit;
hh = u.sprite_height * 0.5;
a = point_direction(x, y, u.x, u.y);
p = fx_make(7, u.x, u.y, hh, make_color_rgb(215, 200, 160), 1.9, 16); p.image_angle = a + 60; p._spin = -9;
p = fx_make(7, u.x, u.y, hh, make_color_rgb(150, 30, 20), 1.5, 14); p.image_angle = a + 75; p._spin = -9; p._add = false;
with(fx_make(0, u.x, u.y, hh, make_color_rgb(255, 210, 160), 0.9, 10)) _grow = 1.8;
with(fx_make(1, u.x, u.y, 2, make_color_rgb(110, 90, 60), 1.2, 14)) { _squash = 0.45; _add = false; _alpha = 0.6; }
repeat(6) {
    p = fx_make(0, u.x, u.y, hh, choose(make_color_rgb(120, 170, 40), make_color_rgb(90, 20, 15)), 0.13, 24);
    p._add = false; p._grow = 0.8; p._vx = random_range(-2, 2); p._vy = random_range(-0.8, 0.8); p._vh = random_range(1, 2.6); p._grav = 0.18;
}
