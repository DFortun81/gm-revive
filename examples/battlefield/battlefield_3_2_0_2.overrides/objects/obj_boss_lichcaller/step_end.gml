var i, u;
event_inherited();
if(dead || global.toggle_pause) exit;

_bolt_cooldown -= 1;
_mend_cooldown -= 1;
_volley_cooldown -= 1;

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

if(_cast != 0) {
    _destx = x;
    _desty = y;
    // Wind Shear (or anything else) knocked the cast bar back
    if(_raid_casting && _silenced <= 0 && _attackcastwait < _last_wait - 1) _setbacks += 1;
    _attackcastwait += 1;
    _last_wait = _attackcastwait;
    if(_attackcastwait >= _attackcasttime) {
        if(_cast == 1) {
            if(units_exists(_target)) {
                if(!_target.dead) unit_damage(_target, c_purple, _bolt_damage * _enrage_mult);
            }
            _bolt_cooldown = _bolt_cooldown_time;
        }
        else if(_cast == 2) {
            unit_heal(id, round(_maxhealth * _mend_fraction));
            create_text_effect(x, y, c_lime, "-dark mending-");
            _mends_landed += 1;
            _mend_cooldown = _mend_cooldown_time;
        }
        else if(_cast == 3) {
            for(i = 0; i < ds_list_size(_enemylist); i += 1) {
                u = ds_list_find_value(_enemylist, i);
                if(!u.dead) unit_damage(u, c_purple, _volley_damage * _enrage_mult, true);
            }
            create_text_effect(x, y, c_purple, "-shadow volley-");
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
    create_text_effect(x, y, c_lime, "-casting dark mending-");
}
else if(_volley_cooldown <= 0) {
    _cast = 3; _raid_casting = true; _attackcasttime = _volley_casttime;
    _message = "Kneel before the shadow!";
    create_text_effect(x, y, c_purple, "-casting shadow volley-");
}
else if(_bolt_cooldown <= 0 && point_distance(x, y, _target.x, _target.y) < range_cast) {
    _cast = 1; _raid_casting = false; _attackcasttime = _bolt_casttime;
}
if(_cast != 0) {
    _attackcastwait = 1;
    _last_wait = 1;
    _destx = x;
    _desty = y;
}
