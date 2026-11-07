// lich_cast_fx(cast, progress);
// The Lichcaller's casts show while they build (gm-revive overrides): Dark Mending draws green-black
// motes spiralling into it over a turning sigil; Shadow Volley gathers violet darkness over a sigil that
// grows as the cast bar fills. A Shadow Bolt just glows in its hands. (Progress 0..1.)
////////////////////////////////////////////////////////////////////////////////////////////
var c, k, p;
c = argument0; k = argument1;
if(c == 1) {
    if(irandom(1) == 0) { p = fx_make(0, x + random_range(-8, 8), y, sprite_height * 0.6 + random_range(-4, 4), make_color_rgb(150, 70, 230), 0.25 + 0.2 * k, 8); p._grow = 0.6; }
    exit;
}
if(c == 2) {
    if(_attackcastwait mod 10 == 1) { p = fx_make(10, x, y, 0, make_color_rgb(70, 200, 90), 2.4, 14); p._squash = 0.45; p._spin = 4; p.image_angle = random(360); p._dz = -40; }
    repeat(2) {
        p = fx_make(4, x, y, random(sprite_height), choose(make_color_rgb(90, 220, 100), make_color_rgb(20, 40, 20)), random_range(0.2, 0.3), 40);
        p._master = id; p._ang = random(360); p._rad = 44 + random(16); p._ch = sprite_height * 0.5; p._spin = 7;
        if(p._col == make_color_rgb(20, 40, 20)) p._add = false;
    }
    exit;
}
if(c == 3) {
    if(_attackcastwait mod 8 == 1) { p = fx_make(10, x, y, 0, make_color_rgb(150, 60, 230), 1.6 + 2.6 * k, 12); p._squash = 0.45; p._spin = -5; p.image_angle = random(360); p._dz = -40; }
    if(irandom(1) == 0) {
        p = fx_make(0, x + random_range(-20, 20), y + random_range(-10, 10), random(sprite_height), make_color_rgb(35, 0, 50), random_range(0.3, 0.5), 26);
        p._add = false; p._vh = random_range(0.5, 1.2); p._grow = 0.5; p._alpha = 0.8;
    }
    with(fx_make(0, x, y, sprite_height * 0.6, make_color_rgb(150, 70, 240), 0.4 + 0.9 * k, 4)) _grow = 1;
}
