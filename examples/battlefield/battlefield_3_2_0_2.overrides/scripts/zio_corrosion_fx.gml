// zio_corrosion_fx(unit);
// Corrosion eats at a unit (gm-revive overrides): acid bubbles swelling and popping on it, green droplets
// splashing off, a sickly haze at its feet, and a green sheen on it for a moment (obj_fx_aura kind 11).
////////////////////////////////////////////////////////////////////////////////////////////
var u, p, hh, c;
u = argument0;
if(!units_exists(u)) exit;
hh = u.sprite_height;
repeat(5) {
    c = choose(make_color_rgb(150, 230, 40), make_color_rgb(200, 240, 60), make_color_rgb(90, 200, 50));
    p = fx_make(9, u.x + random_range(-10, 10), u.y, random_range(4, hh * 0.8), c, random_range(0.25, 0.4), 10 + irandom(12));
    p._vh = random_range(0.2, 0.6);
}
repeat(5) {
    p = fx_make(0, u.x, u.y, random_range(hh * 0.3, hh * 0.7), make_color_rgb(120, 200, 30), 0.12, 22);
    p._add = false; p._grow = 0.8; p._vx = random_range(-1.6, 1.6); p._vy = random_range(-0.6, 0.6); p._vh = random_range(0.8, 2); p._grav = 0.15;
}
with(fx_make(0, u.x, u.y, 3, make_color_rgb(110, 170, 30), 1.1, 40)) { _add = false; _squash = 0.45; _alpha = 0.45; _grow = 1.4; }
with(u) {
    if(!variable_local_exists("_acid_timer")) _acid_timer = 0;
    if(_acid_timer <= 0) with(instance_create(x, y, obj_fx_aura)) { _master = other.id; _kind = 11; }
    _acid_timer = room_speed * 1.5;
}
