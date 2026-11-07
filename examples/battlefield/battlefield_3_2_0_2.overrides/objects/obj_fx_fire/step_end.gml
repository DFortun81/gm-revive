if(global.toggle_pause) exit;
_life += 1;
if(_life >= _maxlife) { instance_destroy(); exit; }
x += _vx; y += _vy; _h += _vh;
_vx *= 0.9; _vy *= 0.9;
if(_kind == 2) {
    // Embers fall and settle on the ground
    _vh -= 0.12;
    if(_h <= 0) { _h = 0; _vh = 0; _vx *= 0.5; _vy *= 0.5; }
}
else _vh *= 0.96;
if(_kind == 3) depth = -y - 8; else depth = -y - 1;
