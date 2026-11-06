// Shared raid boss AI: enemy list, health scaling, enrage, threat target, movement, melee swing.
// Children run their own abilities after event_inherited(), when _target is a unit.
var enemies, i, u, best, bestthreat, cur, d, dir;
event_inherited();
if(dead || global.toggle_pause) exit;

_swing_cooldown -= 1;

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

if(!_enraged && _fight_steps > _enrage_time) {
    _enraged = true;
    _enrage_mult = 2;
    _swing_damage *= 2;
    _swing_speed = round(_swing_speed / 1.5);
    _blendcolor = make_color_rgb(255, 110, 80);
    create_text_effect(x, y, c_red, "-enraged-");
    _message = raid_boss_display_name(_bossid) + " goes into a berserker rage!";
}

// Threat: keep the current target unless someone passes it by 10% (or it's gone)
best = -1;
bestthreat = -1;
for(i = 0; i < enemies; i += 1) {
    u = ds_list_find_value(_enemylist, i);
    if(u._polymorphed || u._stealthed) continue;
    if(u._raid_threat > bestthreat || (u._raid_threat == bestthreat && point_distance(x, y, u.x, u.y) < point_distance(x, y, best.x, best.y))) {
        bestthreat = u._raid_threat;
        best = u;
    }
}
if(best == -1) { _target = -1; exit; }
cur = -1;
if(units_exists(_target)) {
    if(!_target.dead && _target._faction != _faction && ds_list_find_index(_enemylist, _target) != -1) cur = _target;
}
if(cur == -1 || bestthreat > cur._raid_threat * _threat_switch) {
    if(best != cur && cur != -1) create_text_effect(best.x, best.y, c_red, "-aggro-");
    _target = best;
}

d = point_distance(x, y, _target.x, _target.y);
_direction = point_direction(x, y, _target.x, _target.y);
_dir = deg_to_dir(_direction);
if((_melee && d > range_melee) || (!_melee && d > _keep_range)) {
    dir = point_direction(_target.x, _target.y, x, y);
    if(_melee) {
        _destx = round(_target.x + cos(degtorad(dir)) * (range_melee - 4));
        _desty = round(_target.y - sin(degtorad(dir)) * (range_melee - 4));
    }
    else {
        _destx = round(_target.x + cos(degtorad(dir)) * (_keep_range - 4));
        _desty = round(_target.y - sin(degtorad(dir)) * (_keep_range - 4));
    }
}
else {
    _destx = x;
    _desty = y;
    if(_idle_animate) image_single = _dir * 4 + floor(_subindex mod 4); else image_single = _dir * 4;
    if(_melee && _swing_cooldown <= 0) {
        unit_damage(_target, c_red, _swing_damage * (0.9 + random(0.2)));
        _swing_cooldown = _swing_speed;
    }
}
depth = -y;
