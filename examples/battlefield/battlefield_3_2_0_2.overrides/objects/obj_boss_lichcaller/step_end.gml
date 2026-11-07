var i, u, p, k, n2, pick, tries;
event_inherited();
if(dead || global.toggle_pause) exit;

_bolt_cooldown -= 1;
_mend_cooldown -= 1;
_volley_cooldown -= 1;
_frost_cooldown -= 1;
_blast_cooldown -= 1;

// Frostbolt Volley: instant, so it goes off whatever else is happening, even mid-cast
if(_frost_cooldown <= 0 && !_stunned && ds_list_size(_enemylist) > 0) {
    var n;
    n = 0;
    for(i = 0; i < ds_list_size(_arealist); i += 1) {
        u = ds_list_find_value(_arealist, i);
        if(units_exists(u)) {
            if(!u.dead && unit_dist(id, u) < _frost_range) {
                with(instance_create(x, y, obj_frostbolt)) {
                    _master = u;
                    _damage = other._frost_damage * other._enrage_mult;
                    _h = other.sprite_height * 0.6;
                    _speed = 4.5 + random(1.5);
                }
                n += 1;
            }
        }
    }
    if(n > 0) {
        _frost_volleys += 1;
        create_text_effect(x, y, c_aqua, "-frostbolt volley-"); boss_sfx(snd_bfx_frostbolt_volley);
        _message = "Feel the chill of the grave!";
        _frost_message_timer = room_speed * 2;
        p = fx_make(0, x, y, sprite_height * 0.6, make_color_rgb(100, 180, 255), 1.3, 16);
        with(fx_make(1, x, y, 0, make_color_rgb(150, 215, 255), 1.8, 18)) _squash = 0.5;
    }
    _frost_cooldown = _frost_cooldown_time;
}
// (gm-revive overrides) Frost Blast: a few raid members (not the tank) frozen solid for a moment
if(_blast_cooldown <= 0 && !_stunned && ds_list_size(_enemylist) > 1) {
    n2 = 0; tries = 0;
    while(n2 < _blast_count + (ds_list_size(_enemylist) > 20) && tries < 30) {
        tries += 1;
        u = ds_list_find_value(_enemylist, irandom(ds_list_size(_enemylist) - 1));
        if(u == _target || u.dead || u._stunimmune) continue;
        if(u._stunned) continue;
        if(unit_stun(u, _blast_duration)) {
            unit_damage(u, c_aqua, _blast_damage * _enrage_mult);
            with(instance_create(u.x, u.y, obj_fx_aura)) { _master = u; _kind = 13; }
            lich_frostblast_fx(u);
            n2 += 1;
        }
    }
    if(n2 > 0) {
        create_text_effect(x, y, c_aqua, "-frost blast-"); boss_sfx(snd_bfx_frost_blast);
        _message = "Be still... forever.";
        _frost_message_timer = room_speed * 2;
        _blasts += 1;
    }
    _blast_cooldown = _blast_cooldown_time;
}
if(_frost_message_timer > 0) {
    _frost_message_timer -= 1;
    if(_frost_message_timer <= 0 && _cast == 0) _message = "";
}

// Kicked (unit_interrupt sets the flag): the spell is lost and comes back a bit sooner
if(_raid_cast_interrupted) {
    _raid_cast_interrupted = false;
    _kicks += 1;
    if(_cast == 2) _mend_cooldown = _retry_time;
    if(_cast == 3) _volley_cooldown = _retry_time;
    _cast = 0;
    _raid_casting = false;
    _attackcastwait = 0;
    _message = "";
}

// (gm-revive overrides) Locked out (Wind Shear or the end of a Kick): nothing new gets started until it
// wears off, and a spell in progress is held at the start of its cast (a setback), to carry on from
// there afterwards. It used to start a spell every step, which the lockout reset, so a 1% cast bar sat
// over it the whole time.
if(_silenced > 0) {
    if(_cast != 0 && _raid_casting && _last_wait > 1) _setbacks += 1;
    if(_cast == 1) { _cast = 0; _raid_casting = false; }   // a Shadow Bolt is just lost
    _attackcastwait = 0;
    _last_wait = 0;
    exit;
}
if(_cast != 0) {
    _destx = x;
    _desty = y;
    // Wind Shear (or anything else) knocked the cast bar back
    if(_raid_casting && _silenced <= 0 && _attackcastwait < _last_wait - 1) _setbacks += 1;
    _attackcastwait += 1;
    _last_wait = _attackcastwait;
    lich_cast_fx(_cast, _attackcastwait / max(1, _attackcasttime));
    if(_attackcastwait >= _attackcasttime) {
        if(_cast == 1) {
            if(units_exists(_target)) {
                if(!_target.dead) with(instance_create(x, y, obj_frostbolt)) { _master = other._target; _damage = other._bolt_damage * other._enrage_mult; _h = other.sprite_height * 0.6; _speed = 6; _shadow = true; }
            }
            _bolt_cooldown = _bolt_cooldown_time;
        }
        else if(_cast == 2) {
            unit_heal(id, round(_maxhealth * _mend_fraction));
            create_text_effect(x, y, c_lime, "-dark mending-"); boss_sfx(snd_bfx_dark_mending);
            lich_mend_fx();
            _mends_landed += 1;
            _mend_cooldown = _mend_cooldown_time;
        }
        else if(_cast == 3) {
            for(i = 0; i < ds_list_size(_arealist); i += 1) {
                u = ds_list_find_value(_arealist, i);
                if(!u.dead) with(instance_create(x, y, obj_frostbolt)) { _master = u; _damage = other._volley_damage * other._enrage_mult; _h = other.sprite_height * 0.7; _speed = 5 + random(2); _shadow = true; _quiet = true; }
            }
            create_text_effect(x, y, c_purple, "-shadow volley-"); boss_sfx(snd_bfx_shadow_volley);
            with(fx_make(1, x, y, 0, make_color_rgb(40, 0, 60), 5, 26)) { _squash = 0.45; _add = false; _alpha = 0.7; }
            with(fx_make(1, x, y, 0, make_color_rgb(170, 80, 255), 3.6, 20)) _squash = 0.45;
            with(fx_make(0, x, y, sprite_height * 0.6, make_color_rgb(200, 140, 255), 1.4, 14)) _grow = 1.6;
            _volleys_landed += 1;
            _volley_cooldown = _volley_cooldown_time;
        }
        _cast = 0;
        _raid_casting = false;
        _attackcastwait = 0;
        _last_wait = 0;
        _message = "";
    }
    exit;
}

if(!units_exists(_target)) exit;
if(_mend_cooldown <= 0 && _health < _maxhealth * 0.95) {
    _cast = 2; _raid_casting = true; _attackcasttime = _mend_casttime;
    _message = "Darkness, mend me!";
    create_text_effect(x, y, c_lime, "-casting dark mending-"); boss_sfx(snd_bfx_lich_cast);
}
else if(_volley_cooldown <= 0) {
    _cast = 3; _raid_casting = true; _attackcasttime = _volley_casttime;
    _message = "Kneel before the shadow!";
    create_text_effect(x, y, c_purple, "-casting shadow volley-"); boss_sfx(snd_bfx_lich_cast);
}
else if(_bolt_cooldown <= 0 && unit_dist(id, _target) < range_cast) {
    _cast = 1; _raid_casting = false; _attackcasttime = _bolt_casttime;
}
if(_cast != 0) {
    _attackcastwait = 1;
    _last_wait = 1;
    _destx = x;
    _desty = y;
}
