if(global.toggle_pause) exit;
_life += 1;
if(_life >= _maxlife) {
    if(_kind == 9) with(fx_make(1, x, y, _h, _col, _size * 1.3, 8)) { _squash = 1; _alpha = 0.8; }
    instance_destroy(); exit;
}
if(_kind == 4) {
    if(!instance_exists(_master)) { instance_destroy(); exit; }
    _ang += _spin;
    _rad *= 0.92;
    _h += (_ch - _h) * 0.1;
    x = _master.x + lengthdir_x(_rad, _ang);
    y = _master.y + lengthdir_y(_rad, _ang) * 0.5;
    if(_rad < 1.5) { instance_destroy(); exit; }
}
else {
    x += _vx; y += _vy; _h += _vh;
    _vh -= _grav;
    if(_grav > 0 && _h < 0) { _h = 0; _vh = 0; _vx *= 0.6; _vy *= 0.6; }
    _vx *= _drag; _vy *= _drag;
    image_angle += _spin;
}
depth = -y - _dz;
