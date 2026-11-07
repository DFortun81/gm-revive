var i, best, bestsc, sc, d, dir, u, p;
event_inherited();
if(global.toggle_pause) exit;

// Killed once: rise again as an Ultima Demon
if(dead && !_reborn && instance_exists(_master)) {
    if(!_master.dead) {
        dead = false;
        _reborn = true;
        image_alpha = 1;
        _blendcolor = c_white;
        sprite_index = spr_ultima_demon;
        _health = _maxhealth;
        _casting = false; _attackcastwait = 0; _stunned = false; _stun_timer = 0;
        _attackdamage = 15;
        _normal_movespeed = 1.1; _movespeed = _normal_movespeed;
        _ultima_cooldown_time = room_speed * 8;
        _ultima_cooldown = room_speed * 2;
        _ultima_damage = 80;
        _ultima_radius = 70;
        p = fx_make(0, x, y, 20, make_color_rgb(120, 60, 200), 1.6, 20); p._add = false; p._grow = 1.8;
        with(fx_make(1, x, y, 0, make_color_rgb(170, 110, 255), 2, 22)) _squash = 0.5;
        create_text_effect(x, y, c_purple, "-" + string_lower(_name) + " rises as an ultima demon-");
        _message = "This body is but a vessel...";
        _message_timer = room_speed * 2;
    }
}
if(dead) exit;
if(variable_local_exists("_message_timer")) { if(_message_timer > 0) { _message_timer -= 1; if(_message_timer <= 0) _message = ""; } }
if(_stunned || _polymorphed) { _casting = false; _attackcastwait = 0; exit; }

_attackcooldown -= 1;
_stitch_cooldown -= 1;
_death_cooldown -= 1;
_ultima_cooldown -= 1;

// Casting Ultima (Kick / Wind Shear stop it: unit_interrupt clears _casting)
if(_casting) {
    _destx = x; _desty = y;
    if(_silenced > 0) { _casting = false; _attackcastwait = 0; exit; }
    _attackcastwait += 1;
    if(_attackcastwait >= _ultima_casttime) {
        _casting = false; _attackcastwait = 0;
        if(units_exists(_ultima_target)) marquis_ultima(_ultima_target.x, _ultima_target.y, _ultima_damage, _ultima_radius);
        _ultima_cooldown = _ultima_cooldown_time;
    }
    exit;
}

// Healers and casters first (they count as 150 px closer), otherwise the nearest enemy
best = -1;
bestsc = 999999;
with(obj_unit) {
    if(_faction != other._faction && !dead && !_stealthed && _jobclass != class_mirrorimage) {
        sc = point_distance(x, y, other.x, other.y);
        if(_jobclass == class_healer || _jobclass == class_caster) sc -= 150;
        if(sc < bestsc) { bestsc = sc; best = id; }
    }
}
_target = best;
if(best == -1) { _destx = x; _desty = y; exit; }
d = point_distance(x, y, best.x, best.y);
_direction = point_direction(x, y, best.x, best.y);
_dir = deg_to_dir(_direction);

// Ultima: magic damage round the target (cast)
if(_ultima_cooldown <= 0 && d < range_cast) {
    _casting = true; _attackcastwait = 1; _attackcasttime = _ultima_casttime;
    _ultima_target = best;
    create_text_effect(x, y, c_purple, "-casting ultima-");
    exit;
}
if(!_reborn) {
    // Shadow Stitch: Stop on a raid member in casting range, healers first
    if(_stitch_cooldown <= 0) {
        u = -1; bestsc = 999999;
        with(obj_unit) {
            if(_faction != other._faction && !dead && !_stunned && !_stunimmune && _jobclass != class_mirrorimage && _bossid == -1) {
                sc = point_distance(x, y, other.x, other.y);
                if(sc < range_cast) {
                    if(_jobclass == class_healer || _jobclass == class_paladin || _jobclass == class_shaman || _jobclass == class_druid) sc -= 200;
                    if(sc < bestsc) { bestsc = sc; u = id; }
                }
            }
        }
        if(u != -1) {
            if(unit_stun(u, _stitch_duration)) {
                create_text_effect(u.x, u.y, c_purple, "-shadow stitch-");
                p = fx_make(5, u.x, u.y, u.sprite_height * 0.5, make_color_rgb(80, 40, 120), 0.35, 14); p._x1 = x; p._y1 = y; p._h1 = sprite_height * 0.5; p._add = false;
                with(fx_make(1, u.x, u.y, 0, make_color_rgb(90, 40, 140), 1, 16)) { _squash = 0.5; _add = false; }
            }
            _stitch_cooldown = _stitch_cooldown_time;
        }
    }
}
if(d > _attackrange) {
    dir = point_direction(best.x, best.y, x, y);
    _destx = round(best.x + cos(degtorad(dir)) * (_attackrange - 2));
    _desty = round(best.y - sin(degtorad(dir)) * (_attackrange - 2));
}
else {
    _destx = x; _desty = y;
    image_single = _dir * 4 + floor(_subindex mod 4);
    if(!_reborn && _death_cooldown <= 0 && best._health < best._maxhealth * 0.12 && best._bossid == -1) {
        // the killing blow
        create_text_effect(best.x, best.y, c_purple, "-death-");
        unit_damage(best, c_purple, best._health + best._absorbamount + 999, true);
        p = fx_make(7, best.x, best.y, best.sprite_height * 0.5, make_color_rgb(150, 40, 60), 1.2, 14); p.image_angle = _direction + 45; p._add = false; p._dz = 3;
        _death_cooldown = _death_cooldown_time;
        _attackcooldown = _attackspeed;
    }
    else if(_attackcooldown <= 0) {
        unit_damage(best, c_orange, _attackdamage);
        _attackcooldown = _attackspeed;
    }
}
depth = -y;
