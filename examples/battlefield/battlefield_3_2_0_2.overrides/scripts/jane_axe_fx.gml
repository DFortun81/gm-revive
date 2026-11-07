// jane_axe_fx(unit, charge);
// Lady Jane's great axe lands (gm-revive overrides): a heavy arc of steel across the unit, sparks, and a
// crack in the ground under it; at the end of a Charge it hits harder still, with stars for the stun.
// (Was the old Heroic Strike sprite.)
////////////////////////////////////////////////////////////////////////////////////////////
var u, p, a, hh, big;
u = argument0; big = argument1;
if(!units_exists(u)) exit;
hh = u.sprite_height * 0.5;
a = point_direction(x, y, u.x, u.y);
p = fx_make(7, u.x, u.y, hh, make_color_rgb(255, 225, 170), 1.6 + big * 0.4, 14); p.image_angle = a - 40; p._spin = 12;
p = fx_make(7, u.x, u.y, hh, make_color_rgb(200, 60, 20), 1.2 + big * 0.3, 12); p.image_angle = a - 25; p._spin = 12; p._add = false; p._alpha = 0.8;
with(fx_make(0, u.x, u.y, hh, make_color_rgb(255, 200, 120), 0.9 + big * 0.4, 10)) _grow = 1.8;
repeat(6 + big * 4) {
    p = fx_make(2, u.x, u.y, hh, make_color_rgb(255, 220, 140), random_range(0.25, 0.4), 16);
    p._vx = random_range(-2.2, 2.2); p._vy = random_range(-0.9, 0.9); p._vh = random_range(0.5, 2.4); p._grav = 0.14;
}
with(fx_make(1, u.x, u.y, 1, make_color_rgb(120, 95, 70), 1.4 + big, 16)) { _squash = 0.45; _add = false; _alpha = 0.6; }
if(big) {
    repeat(6) {
        p = fx_make(0, u.x + random_range(-14, 14), u.y + random_range(-6, 6), 3, make_color_rgb(175, 155, 115), random_range(0.35, 0.55), 26);
        p._add = false; p._squash = 0.55; p._grow = 2; p._alpha = 0.6; p._vx = random_range(-0.8, 0.8);
    }
}
