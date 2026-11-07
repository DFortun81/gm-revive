// blighted_infect_fx(unit);
// Festering Blight takes hold on a unit (gm-revive overrides): a burst of spores, and the disease shows
// on it while it lasts (obj_fx_aura kind 12: a sickly sheen, weeping sores and flies).
////////////////////////////////////////////////////////////////////////////////////////////
var u, p;
u = argument0;
if(!units_exists(u)) exit;
with(fx_make(8, u.x, u.y, u.sprite_height * 0.5, make_color_rgb(170, 210, 60), 1.3, 14)) _squash = 1;
repeat(8) {
    p = fx_make(0, u.x, u.y, u.sprite_height * 0.5, make_color_rgb(120, 150, 40), 0.18, 22);
    p._add = false; p._vx = random_range(-1.4, 1.4); p._vy = random_range(-0.6, 0.6); p._vh = random_range(-0.5, 1); p._grow = 1.5; p._alpha = 0.7;
}
with(instance_create(u.x, u.y, obj_fx_aura)) { _master = u; _kind = 12; }
