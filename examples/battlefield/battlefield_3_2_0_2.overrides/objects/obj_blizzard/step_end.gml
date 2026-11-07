// obj_blizzard (gm-revive overrides: the game's own end step, drawn anew). Ice falls out of the sky all over
// the storm, snow drifts through it and frost spreads on the ground (was the old ice-shard sprite and a
// white pulse); obj_blizzard's draw event lays a cold haze over the area.
var p, a, d;
if(global.toggle_pause) exit;
if(_master != -1 && instance_exists(_master)) {
    if(!_master._blizzard_casting) { instance_destroy(); exit; }
}
else { instance_destroy(); exit; }
_t += 1;
repeat(2) {
    a = random(360); d = sqrt(random(1)) * _r;
    p = fx_make(3, x + lengthdir_x(d, a), y + lengthdir_y(d * 0.5, a), random_range(60, 90), make_color_rgb(190, 230, 255), random_range(0.25, 0.4), 34);
    p._vh = -3.2; p._grav = 0.05; p.image_angle = 270 + random_range(-15, 15); p._spin = 0;
}
if(_t mod 2 == 0) {
    a = random(360); d = sqrt(random(1)) * _r;
    p = fx_make(2, x + lengthdir_x(d, a), y + lengthdir_y(d * 0.5, a), random_range(20, 70), c_white, 0.18, 40);
    p._vh = -0.8; p._vx = random_range(-0.6, 0.2);
}
if(_t mod 14 == 0) with(fx_make(1, x, y, 0, make_color_rgb(170, 220, 255), _r / 15, 26)) { _squash = 0.45; _alpha = 0.6; }
