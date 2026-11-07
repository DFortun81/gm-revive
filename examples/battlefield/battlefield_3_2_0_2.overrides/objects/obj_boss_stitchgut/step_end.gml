var i, u, hs, hsh, d, best, bv, v, a, n, p;
event_inherited();
if(dead || global.toggle_pause || !units_exists(_target)) exit;
_hateful_cooldown -= 1;
_hook_cooldown -= 1;
_spew_cooldown -= 1;

// (gm-revive overrides) Gut Hook: the unit furthest back that isn't his tank, healers and casters first
if(_hook_cooldown <= 0) {
    best = -1; bv = -1;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u == _target || u.dead || u._polymorphed || u._stealthed || u._stunimmune || unit_divine(u)) continue;
        d = unit_dist(id, u);
        if(d < _hook_min_range) continue;
        v = d;
        if(u._jobclass == class_healer || u._jobclass == class_caster) v += 1000;
        if(v > bv) { bv = v; best = u; }
    }
    if(best != -1) {
        with(instance_create(x, y, obj_fx_hook)) { _master = other.id; _victim = best; _damage = other._hook_damage * other._enrage_mult; }
        create_text_effect(x, y, c_orange, "-gut hook-");
        _message = choose("Come here, little one!", "Get over here!", "Stitchgut hungry...");
        _hooks += 1;
        _hook_cooldown = _hook_cooldown_time;
    }
    else _hook_cooldown = room_speed;
}

// (gm-revive overrides) Bile Spew: everyone in a cone in front of him
if(_spew_cooldown <= 0) {
    n = 0;
    for(i = 0; i < ds_list_size(_arealist); i += 1) {
        u = ds_list_find_value(_arealist, i);
        if(u.dead) continue;
        if(unit_dist(id, u) > _spew_range) continue;
        a = abs(((point_direction(x, y, u.x, u.y) - _direction + 540) mod 360) - 180);
        if(a > _spew_angle) continue;
        unit_damage(u, make_color_rgb(150, 220, 60), _spew_damage * _enrage_mult);
        zio_corrosion_fx(u);
        n += 1;
    }
    stitch_spew_fx(_direction);
    create_text_effect(x, y, c_lime, "-bile spew-");
    _spew_cooldown = _spew_cooldown_time;
}

if(_hateful_cooldown > 0) exit;

// Hateful Strike
d = unit_dist(id, _target);
hs = -1;
hsh = -1;
for(i = 0; i < ds_list_size(_enemylist); i += 1) {
    u = ds_list_find_value(_enemylist, i);
    if(u == _target || u._polymorphed) continue;
    if(unit_dist(id, u) <= range_melee + 12 && u._health > hsh) {
        hsh = u._health;
        hs = u;
    }
}
if(hs == -1 && d <= range_melee) hs = _target;
if(hs != -1) {
    stitch_hateful_fx(hs);
    create_text_effect(x, y, c_red, "-hateful strike-");
    unit_damage(hs, c_red, _hateful_damage * _enrage_mult);
    _hateful_cooldown = _hateful_cooldown_time;
}
