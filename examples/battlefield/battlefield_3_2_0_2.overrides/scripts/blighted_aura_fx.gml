// blighted_aura_fx();
// Blight Aura ticks (gm-revive overrides): a sickly ring of rot rolls out along the ground from The Blighted
// and spores drift up off the units it touches. (Was a flat lime disc.)
////////////////////////////////////////////////////////////////////////////////////////////
var i, u, p, n;
with(fx_make(1, x, y, 0, make_color_rgb(60, 85, 15), 16, 46)) { _squash = 0.45; _add = false; _alpha = 0.8; }
with(fx_make(1, x, y, 0, make_color_rgb(180, 225, 70), 12, 36)) { _squash = 0.45; _alpha = 0.85; }
with(fx_make(1, x, y, 0, make_color_rgb(90, 120, 25), 7, 26)) { _squash = 0.45; _add = false; _alpha = 0.7; }
with(fx_make(0, x, y, 6, make_color_rgb(90, 110, 30), 1.4, 30)) { _squash = 0.5; _add = false; _alpha = 0.5; _grow = 1.6; }
n = ds_list_size(_arealist);
for(i = 0; i < n; i += 1) {
    u = ds_list_find_value(_arealist, i);
    if(u.dead || irandom(1) != 0) continue;
    p = fx_make(0, u.x + random_range(-8, 8), u.y, random(u.sprite_height * 0.6), make_color_rgb(170, 210, 60), random_range(0.22, 0.32), 30);
    p._vh = random_range(0.4, 0.9); p._grow = 1.4; p._add = (irandom(1) == 0);
}
