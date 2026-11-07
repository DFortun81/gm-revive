// lich_frostblast_fx(unit);
// Frost Blast freezes a unit (gm-revive overrides): a burst of frost and flying ice as the block forms
// round it (the block itself is obj_fx_aura kind 13).
////////////////////////////////////////////////////////////////////////////////////////////
var u, p;
u = argument0;
if(!units_exists(u)) exit;
with(fx_make(0, u.x, u.y, u.sprite_height * 0.5, make_color_rgb(170, 225, 255), 1.3, 14)) _grow = 1.5;
with(fx_make(1, u.x, u.y, 1, make_color_rgb(150, 215, 255), 1.8, 16)) _squash = 0.45;
repeat(8) {
    p = fx_make(3, u.x, u.y, u.sprite_height * 0.5, make_color_rgb(190, 235, 255), random_range(0.25, 0.4), 22);
    p._vx = random_range(-1.8, 1.8); p._vy = random_range(-0.8, 0.8); p._vh = random_range(0.5, 2); p._grav = 0.12;
    p._spin = random_range(-15, 15); p.image_angle = random(360);
}
