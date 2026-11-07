// vaelric_mist_reform();
// Count Vaelric comes back in phase after Mist Step (gm-revive overrides). He reforms behind his target
// (or, if it's gone, whoever on the field is worst hurt) as long as that's well inside the screen;
// otherwise on the target's side toward the middle of the field, so he never lands off screen.
////////////////////////////////////////////////////////////////////////////////////////////
var t, i, u, val, best, dir, mx0, my0, mx1, my1, nx, ny;
t = -1;
if(ds_list_find_index(_enemylist, _target) >= 0) t = _target;
else {
    best = 1000;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        val = (u._health + u._absorbamount) / u._maxhealth;
        if(val < best) { best = val; t = u; }
    }
}
if(t != -1) {
    _target = t;
    mx0 = 48; my0 = 80; mx1 = room_width - 48; my1 = room_height - 48;
    dir = degtorad(t._direction - 180);
    nx = t.x + cos(dir) * (range_melee * 3);
    ny = t.y - sin(dir) * (range_melee * 3);
    if(nx < mx0 || nx > mx1 || ny < my0 || ny > my1) {
        dir = degtorad(point_direction(t.x, t.y, room_width / 2, room_height / 2));
        nx = t.x + cos(dir) * (range_melee * 3);
        ny = t.y - sin(dir) * (range_melee * 3);
    }
    x = median(mx0, nx, mx1);
    y = median(my0, ny, my1);
}
else _target = id;
_destx = x;
_desty = y;
_phase_time = 0;
_stealthed = false;
_stealthed_visibility = range_melee * 1.25;
with(instance_create(x, y, obj_fx_strip)) { _spr = spr_vaelric_mist; _glow = spr_vaelric_mist_glow; _f0 = 11; _f1 = 0; _len = 18; _master = other.id; }
repeat(3) with(instance_create(x, y, obj_fx_bat)) _ang = random(360);
