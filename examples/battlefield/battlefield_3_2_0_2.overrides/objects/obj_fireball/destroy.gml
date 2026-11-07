// Fireball lands (gm-revive overrides: same damage as the original, plus an impact burst)
var a, sp, busy;
busy = instance_number(obj_fireball) > 12;
if(units_exists(_master)) {
    unit_damage(_master, c_yellow, _attackdamage);
    with(instance_create(x, y, obj_fx_fire)) { _kind = 3; _h = other._h; _maxlife = 14; _size = 0.85; }
    repeat(3 - busy) with(instance_create(x + random_range(-3, 3), y + random_range(-2, 2), obj_fx_fire)) {
        _kind = 0; _h = other._h + random_range(-3, 3); _hot = 0;
        _maxlife = 10 + irandom(6); _size = random_range(0.45, 0.65); _vh = random_range(0.3, 0.7);
    }
    repeat(8 - busy * 4) with(instance_create(x, y, obj_fx_fire)) {
        a = random(360); sp = random_range(1, 2.6);
        _kind = 2; _h = other._h; _maxlife = 18 + irandom(14); _size = random_range(0.2, 0.32);
        _vx = lengthdir_x(sp, a); _vy = lengthdir_y(sp, a) * 0.5; _vh = random_range(0.4, 1.8);
    }
    repeat(2 - busy) with(instance_create(x + random_range(-3, 3), y, obj_fx_fire)) {
        _kind = 1; _h = other._h; _maxlife = 26 + irandom(10); _size = 0.5; _vh = 0.4;
    }
}
else create_text_effect(x, y, c_white, "miss");
