// caster_managem_fx();
// The Caster cracks a Mana Gem: a blue flash, crystal shards and a few rising sparkles. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var h, p, a, sp;
h = sprite_height * 0.5;
p = fx_make(0, x, y, h, make_color_rgb(40, 120, 255), 1, 16); p._grow = 1.8;
p = fx_make(0, x, y, h, c_white, 0.4, 10);
with(fx_make(1, x, y, 0, make_color_rgb(60, 160, 255), 1.3, 18)) _squash = 0.5;
repeat(8) {
    a = random(360); sp = random_range(0.8, 2);
    p = fx_make(3, x, y, h, make_color_rgb(70, 170, 255), random_range(0.36, 0.48), 24 + irandom(8));
    p._vx = lengthdir_x(sp, a); p._vy = lengthdir_y(sp, a) * 0.5; p._vh = random_range(0.8, 2.2);
    p._grav = 0.14; p._spin = random_range(-18, 18); p.image_angle = random(360);
}
repeat(4) {
    p = fx_make(2, x + random_range(-8, 8), y, random_range(h * 0.5, h * 1.6), make_color_rgb(150, 210, 255), 0.4, 20);
    p._vh = 0.5;
}
