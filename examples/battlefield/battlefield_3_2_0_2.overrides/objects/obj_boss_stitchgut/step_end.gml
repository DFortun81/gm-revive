var enemies, i, u, best, bestthreat, cur, d, dir, hs, hsh;
event_inherited();
if(dead || global.toggle_pause) exit;

_swing_cooldown -= 1;
_hateful_cooldown -= 1;

ds_list_clear(_enemylist);
with(obj_unit) {
    if(_faction != other._faction && !dead && _jobclass != class_mirrorimage) ds_list_add(other._enemylist, id);
}
enemies = ds_list_size(_enemylist);
if(enemies == 0) {
    _target = -1;
    _destx = x;
    _desty = y;
    exit;
}

if(!_fight_started) {
    _fight_started = true;
    _maxhealth = _health_per_enemy * enemies;
    _health = _maxhealth;
}
_fight_steps += 1;

// Enrage
if(!_enraged && _fight_steps > _enrage_time) {
    _enraged = true;
    _swing_damage *= 2;
    _hateful_damage *= 2;
    _swing_speed = round(_swing_speed / 1.5);
    _blendcolor = make_color_rgb(255, 110, 80);
    create_text_effect(x, y, c_red, "-enraged-");
    _message = "Stitchgut goes into a berserker rage!";
}

// Threat: keep the current target unless someone passes it by 10% (or it's gone)
best = -1;
bestthreat = -1;
for(i = 0; i < enemies; i += 1) {
    u = ds_list_find_value(_enemylist, i);
    if(u._polymorphed || u._stealthed) continue;
    if(u._stitch_threat > bestthreat || (u._stitch_threat == bestthreat && point_distance(x, y, u.x, u.y) < point_distance(x, y, best.x, best.y))) {
        bestthreat = u._stitch_threat;
        best = u;
    }
}
if(best == -1) exit;
cur = -1;
if(units_exists(_target)) {
    if(!_target.dead && _target._faction != _faction && ds_list_find_index(_enemylist, _target) != -1) cur = _target;
}
if(cur == -1 || bestthreat > cur._stitch_threat * _threat_switch) {
    if(best != cur && cur != -1) create_text_effect(best.x, best.y, c_red, "-aggro-");
    _target = best;
}

d = point_distance(x, y, _target.x, _target.y);
_direction = point_direction(x, y, _target.x, _target.y);
_dir = deg_to_dir(_direction);
if(d > range_melee) {
    dir = point_direction(_target.x, _target.y, x, y);
    _destx = round(_target.x + cos(degtorad(dir)) * (range_melee - 4));
    _desty = round(_target.y - sin(degtorad(dir)) * (range_melee - 4));
}
else {
    _destx = x;
    _desty = y;
    image_single = _dir * 4;
    if(_swing_cooldown <= 0) {
        unit_damage(_target, c_red, _swing_damage * (0.9 + random(0.2)));
        _swing_cooldown = _swing_speed;
    }
}

// Hateful Strike
if(_hateful_cooldown <= 0) {
    hs = -1;
    hsh = -1;
    for(i = 0; i < enemies; i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u == _target || u._polymorphed) continue;
        if(point_distance(x, y, u.x, u.y) <= range_melee + 12 && u._health > hsh) {
            hsh = u._health;
            hs = u;
        }
    }
    if(hs == -1 && d <= range_melee) hs = _target;
    if(hs != -1) {
        create_heroicstrike_effect(hs.x, hs.y);
        create_text_effect(x, y, c_red, "-hateful strike-");
        unit_damage(hs, c_red, _hateful_damage);
        _hateful_cooldown = _hateful_cooldown_time;
    }
}
depth = -y;
