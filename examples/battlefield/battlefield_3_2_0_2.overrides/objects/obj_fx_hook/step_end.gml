var k, d, p;
if(global.toggle_pause) exit;
if(!instance_exists(_master) || !units_exists(_victim)) { instance_destroy(); exit; }
if(_master.dead || _victim.dead) { instance_destroy(); exit; }
_t += 1;
if(_t <= _out) {
    k = _t / _out;
    _hx = _master.x + (_victim.x - _master.x) * k;
    _hy = _master.y + (_victim.y - _master.y) * k;
}
else {
    if(!_bit) {
        _bit = true;
        _sx = _victim.x; _sy = _victim.y;
        d = point_direction(_master.x, _master.y, _victim.x, _victim.y);
        _ex = _master.x + lengthdir_x(unit_hitbox(_master) + 18, d);
        _ey = _master.y + lengthdir_y(unit_hitbox(_master) + 18, d);
        unit_stun(_victim, _pull + room_speed);
        with(fx_make(0, _victim.x, _victim.y, _victim.sprite_height * 0.5, make_color_rgb(255, 120, 90), 0.7, 10)) _grow = 1.6;
        repeat(5) { p = fx_make(0, _victim.x, _victim.y, _victim.sprite_height * 0.5, make_color_rgb(140, 10, 10), 0.12, 20); p._add = false; p._vx = random_range(-1.5, 1.5); p._vh = random_range(0.8, 2); p._grav = 0.16; }
    }
    k = min(1, (_t - _out) / _pull);
    k = 1 - (1 - k) * (1 - k);
    _victim.x = _sx + (_ex - _sx) * k;
    _victim.y = _sy + (_ey - _sy) * k;
    _victim._destx = _victim.x; _victim._desty = _victim.y;
    _hx = _victim.x; _hy = _victim.y;
    if(_t mod 2 == 0) { p = fx_make(0, _victim.x, _victim.y, 2, make_color_rgb(150, 135, 100), 0.3, 16); p._add = false; p._squash = 0.5; p._grow = 1.8; p._alpha = 0.5; }
    if(_t >= _out + _pull) {
        unit_damage(_victim, c_red, _damage);
        with(fx_make(1, _victim.x, _victim.y, 2, make_color_rgb(150, 130, 90), 1.2, 14)) { _squash = 0.45; _add = false; _alpha = 0.6; }
        instance_destroy();
        exit;
    }
}
depth = min(_master.depth, _victim.depth) - 2;
