var i, u, hs, hsh, d;
event_inherited();
if(dead || global.toggle_pause || !units_exists(_target)) exit;
_hateful_cooldown -= 1;
if(_hateful_cooldown > 0) exit;

// Hateful Strike
d = point_distance(x, y, _target.x, _target.y);
hs = -1;
hsh = -1;
for(i = 0; i < ds_list_size(_enemylist); i += 1) {
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
    unit_damage(hs, c_red, _hateful_damage * _enrage_mult);
    _hateful_cooldown = _hateful_cooldown_time;
}
