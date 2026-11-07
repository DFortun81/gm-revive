var n, k, b, side, sx, sy, mx, my, i, u, best, bv, v;
event_inherited();
if(dead || global.toggle_pause || !_fight_started || !units_exists(_target)) exit;
if(_message_timer > 0) {
    _message_timer -= 1;
    if(_message_timer <= 0) _message = "";
}
_brood_cooldown -= 1;
_web_cooldown -= 1;

// (gm-revive overrides) Web Wrap: a strand of web at someone at the back
if(_web_cooldown <= 0) {
    best = -1; bv = -1;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u == _target || u.dead || u._stunimmune || u._stunned || u._polymorphed) continue;
        v = unit_dist(id, u) + random(40);
        if(u._jobclass == class_healer || u._jobclass == class_caster) v += 1000;
        if(v > bv) { bv = v; best = u; }
    }
    if(best != -1) {
        with(instance_create(x, y, obj_frostbolt)) { _master = best; _damage = 0; _h = other.sprite_height * 0.4; _speed = 7; _web = other._web_duration; }
        create_text_effect(x, y, c_white, "-web wrap-"); boss_sfx(snd_bfx_web_wrap);
        _webs += 1;
    }
    _web_cooldown = _web_cooldown_time;
}
if(_brood_cooldown > 0) exit;

// Call a wave in from around the edges of the field (each broodling from its own spot, keeping
// clear of the unit panels down both sides of the screen); faster once enraged
n = _brood_base + ds_list_size(_enemylist) div 5;
mx = 70; my = 40;
for(k = 0; k < n; k += 1) {
    side = irandom(3);
    if(side == 0) { sx = random_range(mx, room_width - mx); sy = my; }
    else if(side == 1) { sx = random_range(mx, room_width - mx); sy = room_height - my; }
    else if(side == 2) { sx = mx; sy = random_range(my, room_height - my); }
    else { sx = room_width - mx; sy = random_range(my, room_height - my); }
    b = instance_create(sx, sy, obj_broodling);
    with(b) {
        _faction = other._faction;
        _mother = other.id;
        depth = -y;
    }
    brood_hatch_fx(sx, sy);
}
_broodlings_hatched += n;
create_text_effect(x, y, c_orange, "-the brood answers-"); boss_sfx(snd_bfx_brood);
_message = "Come, my children!";
_message_timer = room_speed * 2;
_brood_cooldown = _brood_cooldown_time / _enrage_mult;
