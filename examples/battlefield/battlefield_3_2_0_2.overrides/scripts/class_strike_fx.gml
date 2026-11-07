// class_strike_fx(unit, style);
// A heavy melee blow lands (gm-revive overrides; it was the old Heroic Strike sprite for every class).
// Style 0: a sword arc and sparks (Warrior Heroic Strike), 1: a red finishing cut (Execute), 2: three claw
// rakes (Druid Cat and Bear), 3: a golden holy blade (Paladin), 4: a hammer blow of light (Hammer of Justice).
////////////////////////////////////////////////////////////////////////////////////////////
var u, st, p, a, hh, k, c1, c2;
u = argument0; st = argument1;
if(!units_exists(u)) exit;
hh = u.sprite_height * 0.5;
a = point_direction(x, y, u.x, u.y);
switch(st) {
    case 1: c1 = make_color_rgb(255, 90, 60); c2 = make_color_rgb(140, 10, 10); break;
    case 2: c1 = make_color_rgb(255, 240, 220); c2 = make_color_rgb(150, 30, 30); break;
    case 3: case 4: c1 = make_color_rgb(255, 230, 140); c2 = make_color_rgb(200, 140, 30); break;
    default: c1 = make_color_rgb(235, 235, 245); c2 = make_color_rgb(120, 120, 140); break;
}
if(st == 2) {
    for(k = -1; k <= 1; k += 1) {
        p = fx_make(7, u.x + lengthdir_x(k * 5, a + 90), u.y + lengthdir_y(k * 3, a + 90), hh + k * 3, c1, 0.95, 11); p.image_angle = a - 60; p._spin = 6;
    }
    p = fx_make(7, u.x, u.y, hh, c2, 0.9, 10); p.image_angle = a - 55; p._spin = 6; p._add = false; p._alpha = 0.7;
}
else {
    p = fx_make(7, u.x, u.y, hh, c1, 1.5 + (st == 1) * 0.3, 12); p.image_angle = a - 40; p._spin = 11;
    p = fx_make(7, u.x, u.y, hh, c2, 0.95, 10); p.image_angle = a - 30; p._spin = 11; p._add = false; p._alpha = 0.7;
}
with(fx_make(0, u.x, u.y, hh, c1, 0.6, 9)) _grow = 1.6;
repeat(4 + (st == 1) * 3) {
    p = fx_make(2, u.x, u.y, hh, c1, random_range(0.2, 0.3), 14);
    p._vx = random_range(-1.8, 1.8); p._vy = random_range(-0.7, 0.7); p._vh = random_range(0.4, 2); p._grav = 0.14;
}
if(st == 1) repeat(5) { p = fx_make(0, u.x, u.y, hh, make_color_rgb(140, 0, 15), 0.13, 22); p._add = false; p._vx = random_range(-1.5, 1.5); p._vh = random_range(0.8, 2); p._grav = 0.16; }
