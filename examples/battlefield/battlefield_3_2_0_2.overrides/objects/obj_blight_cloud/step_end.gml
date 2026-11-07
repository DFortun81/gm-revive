var p, a, d, f, me;
if(global.toggle_pause) exit;
_t += 1;
if(_t >= _life || !instance_exists(_master)) { instance_destroy(); exit; }
if(_master.dead) { instance_destroy(); exit; }
f = 1;
if(_t < 10) f = _t / 10;
if(_t > _life - 30) f = (_life - _t) / 30;
// rolling puffs and the odd bubble
if(_t mod 2 == 0) {
    // puffs rolling up through the units standing in it (drawn in front of them)
    a = random(360); d = random(_r);
    p = fx_make(0, x + lengthdir_x(d, a), y + lengthdir_y(d * 0.5, a), random_range(4, 30), choose(make_color_rgb(70, 95, 25), make_color_rgb(100, 130, 35), make_color_rgb(55, 75, 20)), random_range(0.8, 1.3) * f, 44);
    p._add = false; p._alpha = 0.55; p._grow = 1.4; p._vx = random_range(-0.3, 0.3); p._vh = 0.25; p._squash = 0.75; p._dz = 6;
}
if(_t mod 7 == 0) {
    a = random(360); d = random(_r * 0.8);
    p = fx_make(9, x + lengthdir_x(d, a), y + lengthdir_y(d * 0.5, a), random(6), make_color_rgb(170, 210, 60), 0.2, 14);
    p._vh = 0.3;
}
// it eats at everyone inside
depth = -y + 20;
if(_t mod (room_speed / 2) == 0) {
    me = id;
    with(obj_unit) {
        if(!dead && _faction != me._master._faction && _bossid == -1 && point_distance(x, y, me.x, me.y) < me._r) unit_damage(id, c_lime, me._tick, true);
    }
}
