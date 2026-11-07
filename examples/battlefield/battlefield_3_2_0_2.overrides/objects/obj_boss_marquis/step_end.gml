var i, u, best, bestv, v, n, nx, ny, h, a, p, d, gold;
event_inherited();
if(dead || global.toggle_pause) exit;
gold = make_color_rgb(255, 205, 70);

_chiri_cooldown -= 1;
_kiku_cooldown -= 1;
_vamp_cooldown -= 1;
_masamune_cooldown -= 1;
_muramasa_cooldown -= 1;

// Celia and Lede join the fight when it starts (they need his faction, which spawn_boss sets after create)
// They start behind him (away from the raid), so the raid's tanks reach him first and the Assassins
// have to go round to get at the back line
if(!_assassins_up && _fight_started) {
    _assassins_up = true;
    a = 0;
    if(units_exists(_target)) a = point_direction(_target.x, _target.y, x, y);
    for(i = 0; i < 2; i += 1) {
        nx = max(24, min(room_width - 24, x + lengthdir_x(55, a) + lengthdir_x(45, a + 90 - i * 180)));
        ny = max(24, min(room_height - 24, y + lengthdir_y(55, a) + lengthdir_y(45, a + 90 - i * 180)));
        with(instance_create(nx, ny, obj_marquis_assassin)) {
            _master = other.id;
            _faction = other._faction;
            _maxhealth = round(other._maxhealth * 0.08);
            _health = _maxhealth;
            _name = "Celia";
            if(i == 1) { _name = "Lede"; sprite_index = spr_assassin_lede; _stitch_cooldown = room_speed * 9; _ultima_cooldown = room_speed * 13; }
        }
    }
    _message = "Celia, Lede... entertain our guests.";
    _message_timer = room_speed * 3;
}
if(_message_timer > 0) { _message_timer -= 1; if(_message_timer <= 0 && _cast == 0) _message = ""; }

// Masamune: Regen and Haste
if(_regen_timer > 0) {
    _regen_timer -= 1;
    if(_regen_timer mod room_speed == 0) unit_heal(id, round(_maxhealth * _regen_fraction));
}
if(_haste_timer > 0) {
    _haste_timer -= 1;
    _swing_cooldown -= 0.6;          // 1.6x swings, on top of the parent's countdown
    _movespeed = _normal_movespeed * 1.5;
}
else _movespeed = _normal_movespeed;

// Interrupted (Kick, Wind Shear)
if(_raid_cast_interrupted) {
    _raid_cast_interrupted = false;
    _kicks += 1;
    if(_cast == 1) _masamune_cooldown = _retry_time;
    if(_cast == 2) _muramasa_cooldown = _retry_time;
    _cast = 0; _raid_casting = false; _attackcastwait = 0; _muramasa_casting = false;
    _message = "";
}
if(_cast != 0) {
    _destx = x; _desty = y;
    _attackcastwait += 1;
    marquis_cast_fx(_cast, _attackcastwait / max(1, _attackcasttime));
    if(_attackcastwait >= _attackcasttime) {
        if(_cast == 1) {
            // Masamune: Regen and Haste for 10 seconds
            _regen_timer = room_speed * 10;
            _haste_timer = room_speed * 10;
            with(instance_create(x, y, obj_fx_aura)) { _master = other.id; _kind = 5; }
            create_text_effect(x, y, c_lime, "-masamune-");
            marquis_masamune_fx();
            _masamune_cooldown = _masamune_cooldown_time;
        }
        else if(_cast == 2) {
            // Muramasa: the ghosts of the sword strike everyone in casting range
            for(i = 0; i < ds_list_size(_enemylist); i += 1) {
                u = ds_list_find_value(_enemylist, i);
                if(!u.dead && unit_dist(id, u) < range_cast) {
                    unit_damage(u, c_purple, _muramasa_damage * _enrage_mult);
                    marquis_ghostblade_fx(u);
                }
            }
            create_text_effect(x, y, c_purple, "-muramasa-");
            with(fx_make(1, x, y, 0, make_color_rgb(60, 10, 50), range_cast / 9, 26)) { _squash = 0.45; _add = false; _alpha = 0.6; }
            with(fx_make(1, x, y, 0, make_color_rgb(220, 120, 200), range_cast / 12, 20)) _squash = 0.45;
            _muramasa_casting = false;
            _muramasa_cooldown = _muramasa_cooldown_time;
        }
        _cast = 0; _raid_casting = false; _attackcastwait = 0; _message = "";
    }
    exit;
}
if(!units_exists(_target)) exit;

// Masamune and Muramasa (casts)
if(_masamune_cooldown <= 0 && (_health < _maxhealth * 0.9 || _haste_timer <= 0)) {
    _cast = 1; _raid_casting = true; _attackcasttime = _masamune_casttime; _attackcastwait = 1;
    _message = "Masamune, lend me your edge!";
    create_text_effect(x, y, c_lime, "-casting masamune-");
    exit;
}
if(_muramasa_cooldown <= 0) {
    _cast = 2; _raid_casting = true; _attackcasttime = _muramasa_casttime; _attackcastwait = 1;
    _muramasa_casting = true;
    _message = "Summon all ghosts of the sword! Muramasa!";
    create_text_effect(x, y, c_purple, "-muramasa casting-");
    exit;
}

// Teleport + Chirijiraden: behind a raid member who isn't tanking (anywhere on the field), and strike
if(_chiri_cooldown <= 0) {
    best = -1; bestv = -1;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u == _target || u.dead || u._stealthed || u._polymorphed || u._jobclass == class_mirrorimage) continue;
        v = random(1);
        if(v > bestv) { bestv = v; best = u; }
    }
    if(best != -1) {
        nx = max(24, min(room_width - 24, best.x - lengthdir_x(range_melee - 6, best._direction)));
        ny = max(24, min(room_height - 24, best.y - lengthdir_y(range_melee - 6, best._direction)));
        h = sprite_height * 0.5;
        p = fx_make(0, x, y, h, make_color_rgb(60, 40, 90), 1.2, 14); p._add = false; p._grow = 1.6;
        p = fx_make(5, nx, ny, h, make_color_rgb(150, 130, 200), 0.4, 12); p._x1 = x; p._y1 = y; p._h1 = h;
        x = nx; y = ny; _destx = x; _desty = y; depth = -y;
        p = fx_make(0, x, y, h, make_color_rgb(60, 40, 90), 1, 12); p._add = false;
        _direction = point_direction(x, y, best.x, best.y); _dir = deg_to_dir(_direction); image_single = _dir * 4;
        unit_damage(best, c_red, _chiri_damage * _enrage_mult);
        p = fx_make(7, best.x, best.y, best.sprite_height * 0.5, gold, 1.4, 14); p.image_angle = _direction + 60; p._dz = 3;
        p = fx_make(7, best.x, best.y, best.sprite_height * 0.5, make_color_rgb(255, 245, 200), 1.1, 12); p.image_angle = _direction - 40; p._dz = 3;
        p = fx_make(0, best.x, best.y, best.sprite_height * 0.5, gold, 0.9, 12);
        create_text_effect(x, y, c_yellow, "-chirijiraden-");
        _message = "Chirijiraden!"; _message_timer = room_speed * 1.5;
        _chiri_cooldown = _chiri_cooldown_time;
        exit;
    }
}

// Kikuichimonji: a sweep through everyone in the cone in front of him
if(_kiku_cooldown <= 0) {
    n = 0;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u.dead || unit_dist(id, u) > _kiku_range) continue;
        d = ((point_direction(x, y, u.x, u.y) - _direction + 540) mod 360) - 180;
        if(abs(d) <= _kiku_arc) n += 1;
    }
    if(n >= 2) {
        for(i = 0; i < ds_list_size(_enemylist); i += 1) {
            u = ds_list_find_value(_enemylist, i);
            if(u.dead || unit_dist(id, u) > _kiku_range) continue;
            d = ((point_direction(x, y, u.x, u.y) - _direction + 540) mod 360) - 180;
            if(abs(d) <= _kiku_arc) unit_damage(u, c_yellow, _kiku_damage * _enrage_mult);
        }
        for(i = -1; i <= 1; i += 1) {
            a = _direction + i * _kiku_arc * 0.6;
            p = fx_make(7, x + lengthdir_x(30 + 25 * abs(i), a), y + lengthdir_y(30 + 25 * abs(i), a) * 0.6, sprite_height * 0.45, make_color_rgb(200, 230, 255), 1.5, 12);
            p.image_angle = a; p._dz = 3;
            p = fx_make(7, x + lengthdir_x(65, a), y + lengthdir_y(65, a) * 0.6, sprite_height * 0.45, make_color_rgb(230, 245, 255), 1.2, 14);
            p.image_angle = a; p._dz = 3;
        }
        create_text_effect(x, y, c_white, "-kikuichimonji-");
        _message = "Kikuichimonji!"; _message_timer = room_speed * 1.5;
        _kiku_cooldown = _kiku_cooldown_time;
        exit;
    }
}

// Vampire: bite the nearest raid member who isn't tanking him
if(_vamp_cooldown <= 0) {
    best = -1; bestv = range_cast * 1.5;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u == _target || u.dead || u._stealthed || u._canheal || u._jobclass < 0 || u._jobclass == class_mirrorimage || u._bossid != -1) continue;
        v = unit_dist(id, u);
        if(v < bestv) { bestv = v; best = u; }
    }
    if(best != -1) {
        if(marquis_vampirize(best, id)) {
            marquis_bite_fx(best);
            unit_heal(id, round(_maxhealth * 0.015));
            _message = "Join me, child of the night!"; _message_timer = room_speed * 2;
        }
        _vamp_cooldown = _vamp_cooldown_time;
    }
}
