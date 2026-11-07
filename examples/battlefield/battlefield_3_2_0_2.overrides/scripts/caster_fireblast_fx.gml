// caster_fireblast_fx(target);
// Fire Blast is instant, so instead of a projectile, a ring of flame erupts round the target's feet
// and leaps up past it, with a burst of embers and a scorch ring on the ground. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var t, h, a, i;
t = argument0;
if(!instance_exists(t)) exit;
h = t.sprite_height * 0.4;
with(fx_make(1, t.x, t.y, 0, make_color_rgb(255, 110, 20), 1.3, 16)) _squash = 0.5;
with(instance_create(t.x, t.y + 1, obj_fx_fire)) { _kind = 3; _h = 4; _maxlife = 12; _size = 0.7; }
for(i = 0; i < 12; i += 1) {
    a = i * 30 + random(20);
    with(instance_create(t.x + lengthdir_x(11, a), t.y + lengthdir_y(11, a) * 0.45 + 1, obj_fx_fire)) {
        _kind = 0; _h = random(3); _hot = 0;
        _maxlife = 20 + irandom(8); _size = random_range(0.55, 0.72); _vh = random_range(1.2, 2);
        _vx = lengthdir_x(0.25, a); _vy = lengthdir_y(0.25, a) * 0.45;
    }
}
// a column of flame rising through the middle
repeat(5) with(instance_create(t.x + random_range(-3, 3), t.y + 2, obj_fx_fire)) {
    _kind = 0; _h = random(10); _hot = 0;
    _maxlife = 18 + irandom(8); _size = random_range(0.6, 0.8); _vh = random_range(2, 3);
}
repeat(6) with(instance_create(t.x, t.y, obj_fx_fire)) {
    _kind = 2; _h = random(8); _maxlife = 20 + irandom(12); _size = random_range(0.2, 0.3);
    _vx = random_range(-1.2, 1.2); _vy = random_range(-0.5, 0.5); _vh = random_range(1.5, 2.8);
}
