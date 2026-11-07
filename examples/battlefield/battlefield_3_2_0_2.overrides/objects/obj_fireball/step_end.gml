// Fireball flight (gm-revive overrides: same homing as the original; the trail is now flames that
// cool as they fall behind, a little smoke and the odd ember, using obj_fx_fire)
var px, py, busy;
if(global.toggle_pause) exit;
if(units_exists(_master)) {
    _x = _master.x;
    _y = _master.y;
    if(_master._polymorphed) _height = 2;
    else _height = _master.sprite_height / 2;
}
px = x; py = y;
move_towards_point_ext(_x, _y, 6);
_h += (_height - _h) / 6;
if(round(x) == round(_x) && round(y) == round(_y)) instance_destroy();
else {
    // Flames at this point and halfway back to the last one, so the trail has no gaps. In a big
    // battle (lots of Fireballs in the air) each one sheds less, to keep the frame rate up.
    busy = instance_number(obj_fireball) > 12;
    with(instance_create(x, y, obj_fx_fire)) {
        _kind = 0; _h = other._h + random_range(-1, 1); _hot = 1;
        _maxlife = 7 + irandom(4); _size = random_range(0.42, 0.52); _vh = random_range(0.1, 0.35);
    }
    if(!busy) with(instance_create((x + px) / 2 + random_range(-1, 1), (y + py) / 2 + random_range(-1, 1), obj_fx_fire)) {
        _kind = 0; _h = other._h + random_range(-1.5, 1.5); _hot = 1;
        _maxlife = 6 + irandom(4); _size = random_range(0.34, 0.46); _vh = random_range(0.1, 0.35);
    }
    if(random(1) < 0.2 - busy * 0.1) with(instance_create(px, py, obj_fx_fire)) {
        _kind = 1; _h = other._h; _maxlife = 20 + irandom(8); _size = 0.35; _vh = 0.35;
    }
    if(random(1) < 0.2 - busy * 0.1) with(instance_create(x, y, obj_fx_fire)) {
        _kind = 2; _h = other._h; _maxlife = 22 + irandom(10); _size = random_range(0.2, 0.3);
        _vx = random_range(-0.7, 0.7); _vy = random_range(-0.4, 0.4); _vh = random_range(0, 0.9);
    }
}
depth = -y;
