// charge_fx(target);
// A Warrior charges (gm-revive overrides): dust kicked up where it pushes off and a streak toward the target.
////////////////////////////////////////////////////////////////////////////////////////////
var t, p, a;
t = argument0;
if(!units_exists(t)) exit;
a = point_direction(t.x, t.y, x, y);
repeat(6) {
    p = fx_make(0, x + random_range(-8, 8), y + random_range(-3, 3), 3, make_color_rgb(175, 155, 115), random_range(0.3, 0.5), 24);
    p._add = false; p._squash = 0.55; p._grow = 2; p._alpha = 0.6; p._vx = lengthdir_x(1.2, a + random_range(-30, 30)); p._vy = lengthdir_y(0.6, a);
}
p = fx_make(5, x + lengthdir_x(-30, a), y + lengthdir_y(-30, a), sprite_height * 0.5, make_color_rgb(240, 230, 210), 0.25, 12);
p._x1 = x; p._y1 = y; p._h1 = sprite_height * 0.5;
