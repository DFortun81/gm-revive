var i, u, best, bestsc, sc, n, p, d, dir;

// Her opening exchange (Call to Arms), once a session: everyone holds still while it plays
if(_intro >= 0 && !global.toggle_pause) {
    if(_intro == 0) {
        if(variable_global_exists("jane_met")) _intro = -1;
        else {
            global.jane_met = true;
            _intro_t = -1;
            n = 0;
            with(obj_unit) if(_faction != other._faction && !dead && _bossid == -1 && _jobclass != class_mirrorimage) n += 1;
            if(n == 0) _intro = -1;
            else {
                n = irandom(n - 1);
                with(obj_unit) if(_faction != other._faction && !dead && _bossid == -1 && _jobclass != class_mirrorimage) { if(n == 0) other._intro_t = id; n -= 1; }
                _intro = 1; _intro_timer = 30;
                sound_stop_all();
            }
        }
    }
    if(_intro > 0) {
        global.cutscene_active = true;
        _destx = x; _desty = y;
        _intro_timer -= 1;
        if(_intro_timer <= 0) {
            if(units_exists(_intro_t)) _intro_t._cutscenemessage = "";
            _cutscenemessage = "";
            switch(_intro) {
                case 1: if(units_exists(_intro_t)) _intro_t._cutscenemessage = "We're looking for someone you may know."; _intro_timer = 150; break;
                case 2: _cutscenemessage = "If it's my husband you're after, he's not here right now."; _intro_timer = 160; break;
                case 3: if(units_exists(_intro_t)) _intro_t._cutscenemessage = "In that case, you're coming with us."; _intro_timer = 130; break;
                case 4: _cutscenemessage = "I'm not going anywhere."; _intro_timer = 100; break;
                case 5: if(units_exists(_intro_t)) _intro_t._cutscenemessage = "You don't have a choice."; _intro_timer = 100; break;
                case 6: _cutscenemessage = "No, I do actually..."; _intro_timer = 100; break;
                case 7: _cutscenemessage = "You see... I'm quite good with a blade."; _intro_timer = 130; sound_loop(snd_ladyjane_battle); break;
                default:
                    _intro = -1;
                    global.cutscene_active = false;
                    exit;
            }
            _intro += 1;
        }
        exit;
    }
}

event_inherited();
if(dead || global.toggle_pause) exit;
if(!units_exists(_target)) exit;

_heroic_cooldown -= 1;
_clap_cooldown -= 1;
_charge_cooldown -= 1;
_shout_cooldown -= 1;
_execute_cooldown -= 1;
_bloodrage_cooldown -= 1;
if(_message_timer > 0) { _message_timer -= 1; if(_message_timer <= 0) _message = ""; }

// Bloodrage: a burst of extra damage
if(_bloodrage_timer > 0) { _bloodrage_timer -= 1; if(_bloodrage_timer <= 0) { _dmg_mult = 1; if(!_enraged) _blendcolor = c_white; } }
if(_bloodrage_cooldown <= 0) {
    _bloodrage_cooldown = _bloodrage_cooldown_time;
    _bloodrage_timer = room_speed * 10;
    _dmg_mult = 1.2;
    if(!_enraged) _blendcolor = make_color_rgb(255, 160, 160);
    create_text_effect(x, y, c_red, "-bloodrage-");
    with(instance_create(x, y, obj_fx_aura)) { _master = other.id; _kind = 15; }
    p = fx_make(0, x, y, sprite_height * 0.5, make_color_rgb(200, 30, 30), 1.1, 16); p._add = false; p._grow = 1.6;
}
// Last Stand: once, near death
if(!_laststand_used && _health < _maxhealth * 0.3) {
    _laststand_used = true;
    _laststand_timer = room_speed * 12;
    _damagereduction += 0.3;
    unit_heal(id, round(_maxhealth * 0.12));
    create_text_effect(x, y, c_yellow, "-last stand-");
    with(instance_create(x, y, obj_fx_aura)) { _master = other.id; _kind = 16; }
    _message = "Is that all you've got?"; _message_timer = room_speed * 2;
    with(fx_make(1, x, y, 0, make_color_rgb(255, 200, 80), 1.6, 18)) _squash = 0.5;
}
if(_laststand_timer > 0) { _laststand_timer -= 1; if(_laststand_timer <= 0) _damagereduction -= 0.3; }

// Rend: a bleed on her tank
if(_rend_timer > 0) {
    _rend_timer -= 1;
    if(units_exists(_rend_target)) {
        if(!_rend_target.dead && _rend_timer mod room_speed == 0) unit_damage(_rend_target, c_red, _rend_tick * _enrage_mult);
    }
}

// Charge in progress: rush at the target, then hit and stun it
if(_charging > 0) {
    _charging -= 1;
    if(units_exists(_charge_target)) {
        d = unit_dist(id, _charge_target);
        if(d > range_melee) {
            dir = point_direction(x, y, _charge_target.x, _charge_target.y);
            x += lengthdir_x(min(9, d - range_melee + 2), dir); y += lengthdir_y(min(9, d - range_melee + 2), dir);
            _destx = x; _desty = y; depth = -y;
            with(instance_create(x, y, obj_fx)) { _kind = 0; _h = 14; _col = make_color_rgb(230, 220, 200); _size = 0.5; _maxlife = 12; _add = false; _alpha = 0.6; _grow = 1.6; }
            if(_charging > 0) exit;
        }
        unit_damage(_charge_target, c_red, _charge_damage * _enrage_mult * _dmg_mult);
        unit_stun(_charge_target, _charge_stun);
        jane_axe_fx(_charge_target, true);
        _charging = 0;
    }
    else _charging = 0;
    exit;
}

// Heroic Strike on her tank
if(_heroic_cooldown <= 0 && unit_dist(id, _target) <= range_melee) {
    unit_damage(_target, c_red, _heroic_damage * _enrage_mult * _dmg_mult);
    jane_axe_fx(_target, false);
    create_text_effect(x, y, c_white, "-heroic strike-");
    _heroic_cooldown = _heroic_cooldown_time;
    if(_rend_timer <= room_speed || _rend_target != _target) {
        _rend_target = _target; _rend_timer = _rend_duration;
        create_text_effect(_target.x, _target.y, c_red, "-rend-");
    }
}
// Execute: finish off a target under 20%
if(_execute_cooldown <= 0 && unit_dist(id, _target) <= range_melee && _target._health < _target._maxhealth * 0.2) {
    unit_damage(_target, c_red, _execute_damage * _enrage_mult * _dmg_mult);
    create_text_effect(x, y, c_red, "-execute-");
    fx_spell(_target, "ferocious bite");
    _execute_cooldown = _execute_cooldown_time;
}
// Thunder Clap: everyone close to her
if(_clap_cooldown <= 0) {
    n = 0;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) { u = ds_list_find_value(_enemylist, i); if(!u.dead && unit_dist(id, u) < _clap_range) n += 1; }
    if(n >= 2) {
        for(i = 0; i < ds_list_size(_enemylist); i += 1) {
            u = ds_list_find_value(_enemylist, i);
            if(!u.dead && unit_dist(id, u) < _clap_range) unit_damage(u, c_yellow, _clap_damage * _enrage_mult * _dmg_mult);
        }
        jane_clap_fx();
        create_text_effect(x, y, c_white, "-thunder clap-");
        _clap_cooldown = _clap_cooldown_time;
    }
}
// Intimidating Shout: everyone near her freezes with fear
if(_shout_cooldown <= 0) {
    n = 0;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) { u = ds_list_find_value(_enemylist, i); if(!u.dead && unit_dist(id, u) < _shout_range) n += 1; }
    if(n >= 3) {
        for(i = 0; i < ds_list_size(_enemylist); i += 1) {
            u = ds_list_find_value(_enemylist, i);
            if(!u.dead && unit_dist(id, u) < _shout_range && u != _target) unit_stun(u, _shout_fear);
        }
        create_text_effect(x, y, c_white, "-intimidating shout-");
        _message = "Back off!"; _message_timer = room_speed * 1.5;
        jane_shout_fx();
        _shouts += 1;
        _shout_cooldown = _shout_cooldown_time;
    }
}
// Charge: rush a raid member at range, healers and casters first
if(_charge_cooldown <= 0) {
    best = -1; bestsc = -1;
    for(i = 0; i < ds_list_size(_enemylist); i += 1) {
        u = ds_list_find_value(_enemylist, i);
        if(u.dead || u._stealthed || u == _target) continue;
        d = unit_dist(id, u);
        if(d < _charge_min_range) continue;
        sc = d + random(60);
        if(u._jobclass == class_healer || u._jobclass == class_caster) sc += 150;
        if(sc > bestsc) { bestsc = sc; best = u; }
    }
    if(best != -1) {
        _charge_target = best;
        _charging = room_speed * 2;
        _charges += 1;
        create_charge_effect(x, y);
        create_text_effect(x, y, c_white, "-charge-");
        _charge_cooldown = _charge_cooldown_time;
    }
}
