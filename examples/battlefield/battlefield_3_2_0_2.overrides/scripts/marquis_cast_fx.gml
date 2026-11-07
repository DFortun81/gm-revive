// marquis_cast_fx(cast, progress);
// Marquis Elmdor's casts show as they build (gm-revive overrides). Masamune: pale green-gold light gathers
// along his blade and motes spiral in. Muramasa: a blood-violet sigil spreads under him and the ghosts of
// the sword gather in the air around him, more of them as the cast goes on. (Was a flat pink disc.)
////////////////////////////////////////////////////////////////////////////////////////////
var c, k, p, a, d;
c = argument0; k = argument1;
if(c == 1) {
    p = fx_make(4, x, y, random(sprite_height), choose(make_color_rgb(200, 255, 170), make_color_rgb(255, 230, 140)), random_range(0.2, 0.3), 40);
    p._master = id; p._ang = random(360); p._rad = 36 + random(12); p._ch = sprite_height * 0.55; p._spin = 8;
    with(fx_make(0, x + 8, y, sprite_height * 0.55, make_color_rgb(220, 255, 180), 0.3 + 0.6 * k, 4)) _grow = 1;
    exit;
}
if(c == 2) {
    if(_attackcastwait mod 8 == 1) { p = fx_make(10, x, y, 0, make_color_rgb(200, 60, 140), 2 + 4 * k, 12); p._squash = 0.45; p._spin = -3; p.image_angle = random(360); p._dz = -40; }
    if(irandom(2) == 0) {
        a = random(360); d = random_range(20, 40 + range_cast * 0.5 * k);
        p = fx_make(7, x + lengthdir_x(d, a), y + lengthdir_y(d * 0.5, a), random_range(10, 40), make_color_rgb(230, 170, 230), random_range(0.5, 0.8), 16);
        p.image_angle = random(360); p._spin = random_range(-8, 8); p._alpha = 0.6; p._vh = 0.3;
    }
    if(irandom(1) == 0) {
        p = fx_make(0, x + random_range(-25, 25), y + random_range(-12, 12), random(10), make_color_rgb(70, 10, 50), random_range(0.3, 0.5), 30);
        p._add = false; p._vh = random_range(0.4, 0.9); p._alpha = 0.7; p._grow = 0.6;
    }
}
