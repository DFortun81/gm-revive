// holy_bubble_fx(unit);
// Divine Shield or Blessing of Protection lands on a unit: a golden flash and ring, and the bubble that
// stays round it while it lasts (an obj_fx_aura that ends when the unit loses its golden tint).
// (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u, h, p;
u = argument0;
if(!instance_exists(u)) exit;
h = u.sprite_height * 0.45;
p = fx_make(0, u.x, u.y, h, make_color_rgb(255, 210, 90), 1.1, 16); p._grow = 1.7;
with(fx_make(1, u.x, u.y, 0, make_color_rgb(255, 220, 120), 1.4, 18)) _squash = 0.5;
repeat(6) {
    p = fx_make(2, u.x + random_range(-10, 10), u.y, random_range(2, u.sprite_height), make_color_rgb(255, 230, 140), 0.35, 20);
    p._vh = 0.45;
}
with(instance_create(u.x, u.y, obj_fx_aura)) { _master = u; _kind = 1; }
