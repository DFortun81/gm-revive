// marquis_masamune_fx();
// Masamune lands on Marquis Elmdor (gm-revive overrides): a flash of pale green-gold light, a ring on
// the ground and petals of light rising as Regen and Haste take hold.
////////////////////////////////////////////////////////////////////////////////////////////
var p;
with(fx_make(0, x, y, sprite_height * 0.55, make_color_rgb(210, 255, 180), 1.6, 16)) _grow = 1.5;
with(fx_make(1, x, y, 0, make_color_rgb(190, 255, 170), 3.2, 22)) _squash = 0.45;
with(fx_make(1, x, y, 0, make_color_rgb(255, 230, 140), 2.2, 18)) _squash = 0.45;
repeat(12) {
    p = fx_make(choose(2, 6), x + random_range(-14, 14), y, random(sprite_height), choose(make_color_rgb(200, 255, 170), make_color_rgb(255, 235, 150)), random_range(0.25, 0.35), 30);
    p._vh = random_range(0.8, 1.6); p._spin = random_range(-10, 10);
}
