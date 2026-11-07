// stitch_spew_fx(direction);
// Bile Spew (gm-revive overrides): a fan of green-yellow bile gushing out of Stitchgut's gut in the
// direction he faces, splashing down along the cone.
////////////////////////////////////////////////////////////////////////////////////////////
var d, p, a, s, k;
d = argument0;
for(k = 0; k < 44; k += 1) {
    a = d + random_range(-_spew_angle, _spew_angle);
    s = random_range(2.2, 4.4);
    p = fx_make(choose(0, 0, 9), x + lengthdir_x(10, d), y + lengthdir_y(5, d), sprite_height * 0.45, choose(make_color_rgb(150, 210, 40), make_color_rgb(190, 230, 70), make_color_rgb(110, 160, 30)), random_range(0.25, 0.5), 20 + irandom(12));
    p._add = (irandom(2) == 0); p._grow = 1.3;
    p._vx = lengthdir_x(s, a); p._vy = lengthdir_y(s * 0.5, a); p._vh = random_range(0.2, 1.6); p._grav = 0.12; p._drag = 0.96;
}
// a puddle of bile spreading along the cone
for(k = 1; k <= 3; k += 1) with(fx_make(0, x + lengthdir_x(_spew_range * k / 3.3, d), y + lengthdir_y(_spew_range * k / 6.6, d), 1, make_color_rgb(120, 170, 30), 0.9 + k * 0.45, 46)) { _add = false; _squash = 0.45; _alpha = 0.6; _grow = 1.3; }
