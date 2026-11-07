if(global.toggle_pause) exit;
_t += 1;
if(instance_exists(_master)) {
    x = _master.x; y = _master.y;
    if(_t >= _len) { _master.image_alpha = 1; _master._stealthed_alpha = 1; }
    else { _master.image_alpha = 0; _master._stealthed_alpha = 0; }
}
if(_t >= _len) { instance_destroy(); exit; }
depth = -y - 1;
