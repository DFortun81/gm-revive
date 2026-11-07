// caster_blizzard_fx();
// What a Caster looks like while it channels Blizzard (gm-revive overrides): a frost sigil lies under its
// feet over a cold shadow, snowflakes spiral in to its raised hands, its hands blaze ice-blue, and wisps
// of frost stream up and away towards the storm, so you can tell at a glance who is holding the storm up.
////////////////////////////////////////////////////////////////////////////////////////////
var p, a, d, hh;
hh = sprite_height * 0.5;
if(_attackcastwait mod 12 == 1) {
    p = fx_make(0, x, y, 0, make_color_rgb(20, 50, 110), 2.4, 14); p._add = false; p._squash = 0.45; p._grow = 1; p._alpha = 0.7; p._dz = -41;
    p = fx_make(10, x, y, 0, make_color_rgb(170, 225, 255), 2.0, 16); p._squash = 0.45; p._dz = -40; p._grow = 0.1;
}
repeat(2) {
    p = fx_make(choose(4, 7), x, y, random(sprite_height), choose(c_white, make_color_rgb(140, 200, 255)), random_range(0.3, 0.45), 40);
    p._master = id; p._ang = random(360); p._rad = 32 + random(16); p._ch = hh; p._spin = 8;
}
with(fx_make(0, x, y, hh, make_color_rgb(150, 210, 255), 0.6 + 0.12 * sin(_attackcastwait * 0.3), 4)) _grow = 0.5;
with(fx_make(0, x, y, hh, c_white, 0.25, 4)) _grow = 0.5;
if(_attackcastwait mod 3 == 0) {
    a = point_direction(x, y, _blizzard_x, _blizzard_y); d = point_distance(x, y, _blizzard_x, _blizzard_y);
    p = fx_make(choose(4, 7), x + random_range(-4, 4), y, hh, make_color_rgb(200, 235, 255), random_range(0.35, 0.5), 22);
    p._vx = lengthdir_x(d / 22, a) + random_range(-0.4, 0.4); p._vy = lengthdir_y(d / 22, a) + random_range(-0.3, 0.3); p._vh = 1.6; p._grow = 0;
}
