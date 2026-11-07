if(global.toggle_pause) exit;
_t += 1;
image_index = floor(_t / 3) mod 3;
image_angle -= 12;
if(instance_exists(_master)) { x = _master.x; y = _master.y; }
if(_t >= _timer) { instance_destroy(); exit; }
depth = -(y + 2);
