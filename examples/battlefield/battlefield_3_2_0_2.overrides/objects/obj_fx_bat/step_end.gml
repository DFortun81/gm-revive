if(global.toggle_pause) exit;
_life += 1;
if(_life >= _maxlife) { instance_destroy(); exit; }
x += lengthdir_x(_spd, _ang);
y += lengthdir_y(_spd, _ang) * 0.6;
_h += _vh;
_ang += random_range(-6, 6);
depth = -y - 4;
