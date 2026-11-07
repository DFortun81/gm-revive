// marquis_ghostblade_fx(unit);
// A ghost of the sword strikes a unit in Muramasa (gm-revive overrides): a pale spectral katana slashes
// across it in a blood-violet afterglow, with a second cut on the way back.
////////////////////////////////////////////////////////////////////////////////////////////
var u, p, a, hh;
u = argument0;
if(!units_exists(u)) exit;
hh = u.sprite_height * 0.5; a = random(360);
p = fx_make(7, u.x, u.y, hh, make_color_rgb(240, 200, 255), 1.15, 14); p.image_angle = a; p._spin = 10; p._dz = 3;
p = fx_make(7, u.x, u.y, hh, make_color_rgb(200, 60, 140), 0.9, 12); p.image_angle = a + 120; p._spin = -10; p._dz = 3; p._add = false; p._alpha = 0.8;
with(fx_make(0, u.x, u.y, hh, make_color_rgb(230, 150, 230), 0.6, 10)) _grow = 1.6;
