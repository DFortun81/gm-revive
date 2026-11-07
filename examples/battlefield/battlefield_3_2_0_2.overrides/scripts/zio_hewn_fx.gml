// zio_hewn_fx(unit);
// Hewn, the wind technique, hits a unit (gm-revive overrides): crescent wind blades whip in at it from
// three sides, gusts spiral round it, and dust kicks up at its feet. (The throw itself and its trail are
// in zio_hewn_push.)
////////////////////////////////////////////////////////////////////////////////////////////
var u, p, a, k, hh;
u = argument0;
if(!units_exists(u)) exit;
hh = u.sprite_height * 0.5;
a = random(360);
for(k = 0; k < 3; k += 1) {
    a += 120;
    p = fx_make(7, u.x + lengthdir_x(40, a), u.y + lengthdir_y(20, a), hh, make_color_rgb(215, 235, 255), 0.75, 12);
    p._vx = -lengthdir_x(3.4, a); p._vy = -lengthdir_y(1.7, a);
    p.image_angle = a + 90; p._spin = 14;
}
repeat(6) {
    p = fx_make(4, u.x, u.y, random(hh * 2), make_color_rgb(225, 240, 255), random_range(0.18, 0.26), 30);
    p._master = u; p._ang = random(360); p._rad = 22 + random(10); p._ch = hh; p._spin = 16;
}
repeat(6) {
    a = random(360);
    p = fx_make(0, u.x, u.y, 2, make_color_rgb(175, 155, 115), random_range(0.3, 0.45), 26);
    p._add = false; p._squash = 0.55; p._grow = 2; p._alpha = 0.6;
    p._vx = lengthdir_x(1.2, a); p._vy = lengthdir_y(0.6, a); p._drag = 0.92;
}
