var i, t, ox, oy, dx, dy, l, nx, ny;
if(global.toggle_pause) exit;
if(_life mod 2 == 0) {
    // re-fork: points along the line, pushed sideways at random (none at the ends)
    dx = _x2 - _x1; dy = (_y2 - _h2) - (_y1 - _h1); l = max(1, sqrt(dx * dx + dy * dy));
    nx = -dy / l; ny = dx / l;
    for(i = 0; i <= _n; i += 1) {
        t = i / _n;
        ox = 0; if(i > 0 && i < _n) ox = random_range(-_jag, _jag) * _w * sin(t * pi) * 1.4;
        _px[i] = _x1 + dx * t + nx * ox;
        _py[i] = (_y1 - _h1) + dy * t + ny * ox;
    }
    // a branch off the middle
    _bi = 2 + irandom(_n - 4);
    _bx = _px[_bi] + random_range(-18, 18) * _w;
    _by = _py[_bi] + random_range(-14, 14) * _w;
}
_life += 1;
if(_life >= _maxlife) { instance_destroy(); exit; }
depth = -max(_y1, _y2) - 3;
