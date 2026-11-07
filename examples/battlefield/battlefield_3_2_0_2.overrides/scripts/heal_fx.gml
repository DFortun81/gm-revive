// heal_fx(unit, style);
// A heal lands on a unit (gm-revive overrides; heals used to show only the number). Style 0: a small holy
// heal (Flash Heal, Holy Light), 1: a big one (Greater Heal, Lay on Hands: a shaft of light comes down),
// 2: water (Healing Wave, Lesser Healing Wave, Chain Heal), 3: nature (Nourish), 4: a bandage.
////////////////////////////////////////////////////////////////////////////////////////////
var u, st, p, hh, c1, c2, k, n;
u = argument0; st = argument1;
if(!units_exists(u)) exit;
hh = u.sprite_height * 0.5;
switch(st) {
    case 0: case 1: c1 = make_color_rgb(255, 195, 50); c2 = make_color_rgb(255, 245, 190); break;
    case 2: c1 = make_color_rgb(40, 170, 235); c2 = make_color_rgb(200, 245, 255); break;
    case 3: c1 = make_color_rgb(60, 190, 60); c2 = make_color_rgb(220, 255, 170); break;
    default: c1 = make_color_rgb(235, 235, 225); c2 = c_white; break;
}
if(st == 1) {
    p = fx_make(5, u.x, u.y, hh * 0.4, c1, 0.6, 20); p._x1 = u.x; p._y1 = u.y; p._h1 = hh * 2 + 80;
}
with(fx_make(0, u.x, u.y, hh, c1, 0.9 + (st == 1) * 0.6, 14)) _grow = 1.5;
with(fx_make(0, u.x, u.y, hh, c2, 0.5 + (st == 1) * 0.3, 10)) _grow = 1.4;
with(fx_make(1, u.x, u.y, 1, merge_color(c1, c_black, 0.45), 1.5 + (st == 1) * 0.9, 20)) { _squash = 0.45; _add = false; _alpha = 0.7; }
with(fx_make(1, u.x, u.y, 1, c1, 1.3 + (st == 1) * 0.8, 18)) _squash = 0.45;
n = 4 + (st == 1) * 5;
if(st == 4) n = 2;
for(k = 0; k < n; k += 1) {
    p = fx_make(choose(2, 6), u.x + random_range(-9, 9), u.y, random_range(2, hh * 1.4), choose(c1, c2), random_range(0.26, 0.38), 26);
    p._vh = random_range(0.6, 1.4); p._spin = random_range(-8, 8);
    if(st == 2) { p._kind = 9; p._vh = random_range(0.4, 1); }
}
