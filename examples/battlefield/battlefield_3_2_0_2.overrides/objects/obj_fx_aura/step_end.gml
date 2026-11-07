var on, p;
if(global.toggle_pause) exit;
if(!instance_exists(_master)) { instance_destroy(); exit; }
_t += 1;
x = _master.x; y = _master.y;
if(_kind == 2 || _kind == 3) depth = _master.depth + 1; // behind the unit
else depth = _master.depth - 1;
on = !_master.dead;
switch(_kind) {
    case 0: on = on && _master._stunned; break;
    case 1: on = on && _master._blendcolor == c_yellow; break;
    case 2: on = on && _master._evasion_timer > 0; break;
    case 3: on = on && _master._evocation_casting; break;
    case 4: on = on && instance_exists(_src); if(on) on = _src._swp_timer > 0 && _src._swp_target == _master; break;
}
if(_ending < 0) {
    if(!on) {
        _ending = 10;
        if(_kind == 1) { // the bubble pops
            p = fx_make(1, x, y, _master.sprite_height * 0.45, make_color_rgb(255, 215, 90), 1.3, 14);
            repeat(5) { p = fx_make(2, x + random_range(-10, 10), y, random(_master.sprite_height), make_color_rgb(255, 225, 120), 0.35, 16); p._vh = 0.4; }
        }
    }
}
else {
    _ending -= 1;
    if(_ending <= 0) { instance_destroy(); exit; }
}
if(_ending < 0) {
    if(_kind == 1 && _t mod 9 == 0) {
        p = fx_make(2, x + random_range(-11, 11), y, random_range(4, _master.sprite_height), make_color_rgb(255, 230, 140), 0.3, 18);
        p._vh = 0.3;
    }
    if(_kind == 3 && _t mod 2 == 0) {
        p = fx_make(4, x, y, random(30), make_color_rgb(60, 160, 255), random_range(0.28, 0.36), 45);
        if(irandom(2) == 0) p._col = make_color_rgb(150, 90, 255);
        p._master = _master; p._ang = random(360); p._rad = 24 + random(10);
        p._ch = _master.sprite_height * 0.5; p._spin = 8;
    }
    if(_kind == 4 && _t mod 7 == 0) {
        p = fx_make(0, x + random_range(-7, 7), y, random_range(6, _master.sprite_height * 0.8), make_color_rgb(150, 60, 200), 0.3, 22);
        p._add = false; p._vh = 0.35; p._grow = 1.8; p._alpha = 0.6;
    }
}
