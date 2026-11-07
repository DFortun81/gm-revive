// jane_shout_fx();
// Intimidating Shout (gm-revive overrides): Lady Jane's roar rolls out in three red-orange rings, and
// everyone it freezes shudders.
////////////////////////////////////////////////////////////////////////////////////////////
var k, p;
for(k = 0; k < 3; k += 1) {
    p = fx_make(1, x, y, sprite_height * 0.55, choose(make_color_rgb(255, 120, 60), make_color_rgb(255, 190, 120)), (_shout_range / 13) * (0.55 + k * 0.25), 14 + k * 5);
    p._squash = 0.6; p._alpha = 0.9 - k * 0.2;
}
with(fx_make(0, x, y, sprite_height * 0.6, make_color_rgb(255, 150, 80), 1, 10)) _grow = 1.6;
