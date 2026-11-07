var p, px, py;
if(global.toggle_pause) exit;
if(units_exists(_master)) {
    _x = _master.x;
    _y = _master.y;
    _height = _master.sprite_height / 2;
}
px = x; py = y;
move_towards_point_ext(_x, _y, _speed);
_h += (_height - _h) / 8;
image_angle = point_direction(px, py, x, y);
if(round(x) == round(_x) && round(y) == round(_y)) {
    if(units_exists(_master) && _web > 0) {
        if(!_master.dead) {
            if(unit_stun(_master, _web)) with(instance_create(_master.x, _master.y, obj_fx_aura)) { _master = other._master; _kind = 14; }
        }
        instance_destroy();
        exit;
    }
    if(units_exists(_master) && _wandcol != -1) {
        if(!_master.dead) unit_damage(_master, c_white, _damage);
        with(fx_make(0, x, y, _h, _wandcol, 0.5, 10)) _grow = 1.5;
        repeat(3) { p = fx_make(2, x, y, _h, _wandcol, 0.22, 12); p._vx = random_range(-1, 1); p._vh = random_range(0.3, 1); }
        instance_destroy();
        exit;
    }
    if(units_exists(_master)) {
        if(!_shadow) {
            if(!_master.dead) unit_damage(_master, c_aqua, _damage);
            p = fx_make(0, x, y, _h, make_color_rgb(120, 200, 255), 0.75, 12);
        }
        else {
            if(!_master.dead) unit_damage(_master, c_purple, _damage, _quiet);
            with(fx_make(8, x, y, _h, make_color_rgb(170, 80, 255), 1.0, 12)) _squash = 1;
            with(fx_make(0, x, y, _h, make_color_rgb(30, 0, 45), 0.6, 14)) { _add = false; _grow = 0.6; _alpha = 0.8; }
        }
        repeat(4) {
            p = fx_make(3, x, y, _h, make_color_rgb(160, 225, 255), random_range(0.25, 0.35), 16 + irandom(6));
            if(_shadow) { p._col = make_color_rgb(120, 50, 190); p._add = false; }
            p._vx = random_range(-1.4, 1.4); p._vy = random_range(-0.6, 0.6); p._vh = random_range(0.3, 1.5);
            p._grav = 0.12; p._spin = random_range(-15, 15); p.image_angle = random(360);
        }
    }
    instance_destroy();
    exit;
}
// a trail of frost: a pale glow left behind each step, and now and then a flake
if(_wandcol != -1) { p = fx_make(0, px, py, _h, _wandcol, 0.2, 8); p._grow = 0.5; }
else if(_web > 0) { p = fx_make(5, x, y, _h, make_color_rgb(235, 235, 225), 0.09, 16); p._x1 = px; p._y1 = py; p._h1 = _h; p._add = false; }
else if(_shadow) { p = fx_make(0, px, py, _h, make_color_rgb(40, 0, 60), 0.36, 12); p._grow = 0.5; p._alpha = 0.7; p._add = false; }
else { p = fx_make(0, px, py, _h, make_color_rgb(110, 190, 255), 0.32, 10); p._grow = 0.5; p._alpha = 0.7; }
if(!_shadow && random(1) < 0.3) {
    p = fx_make(2, px, py, _h + random_range(-2, 2), make_color_rgb(200, 235, 255), 0.22, 14);
    p._vh = -0.2;
}
depth = -y;
