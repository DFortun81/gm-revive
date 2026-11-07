// lich_mend_fx();
// Dark Mending lands (gm-revive overrides): a pulse of sickly green light, a ring on the ground and wisps
// rising off the Lichcaller as its wounds knit.
////////////////////////////////////////////////////////////////////////////////////////////
var p;
with(fx_make(0, x, y, sprite_height * 0.55, make_color_rgb(120, 255, 140), 1.8, 18)) _grow = 1.4;
with(fx_make(1, x, y, 0, make_color_rgb(70, 200, 90), 4, 22)) _squash = 0.45;
repeat(14) {
    p = fx_make(choose(0, 2), x + random_range(-16, 16), y, random(sprite_height), choose(make_color_rgb(100, 240, 120), make_color_rgb(30, 60, 30)), random_range(0.2, 0.35), 30);
    p._vh = random_range(0.8, 1.8); p._grow = 0.6;
    if(p._col == make_color_rgb(30, 60, 30)) { p._add = false; p._alpha = 0.8; }
}
