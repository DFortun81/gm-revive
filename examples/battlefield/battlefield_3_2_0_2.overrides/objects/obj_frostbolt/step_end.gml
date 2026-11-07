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
    if(units_exists(_master)) {
        if(!_master.dead) unit_damage(_master, c_aqua, _damage);
        p = fx_make(0, x, y, _h, make_color_rgb(120, 200, 255), 0.75, 12);
        repeat(4) {
            p = fx_make(3, x, y, _h, make_color_rgb(160, 225, 255), random_range(0.25, 0.35), 16 + irandom(6));
            p._vx = random_range(-1.4, 1.4); p._vy = random_range(-0.6, 0.6); p._vh = random_range(0.3, 1.5);
            p._grav = 0.12; p._spin = random_range(-15, 15); p.image_angle = random(360);
        }
    }
    instance_destroy();
    exit;
}
// a trail of frost: a pale glow left behind each step, and now and then a flake
p = fx_make(0, px, py, _h, make_color_rgb(110, 190, 255), 0.32, 10); p._grow = 0.5; p._alpha = 0.7;
if(random(1) < 0.3) {
    p = fx_make(2, px, py, _h + random_range(-2, 2), make_color_rgb(200, 235, 255), 0.22, 14);
    p._vh = -0.2;
}
depth = -y;
