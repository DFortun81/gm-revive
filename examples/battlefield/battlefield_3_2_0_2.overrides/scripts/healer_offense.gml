// healer_offense();
// Called by a Healer when nobody needs healing (or while it is already casting Smite).
// Keeps Shadow Word: Pain on one enemy and casts Smite at the nearest one. A Smite is dropped as
// soon as an ally in sight falls below _offense_panic health. A Healer that is the last of its
// side walks up to enemies so the battle can still end.
// Returns true when the Healer spent this step on offense.
////////////////////////////////////////////////////////////////////////////////////////////
var me, best, bestd, d, alone, panic;
me = id;

// Is anyone on my side in trouble?
panic = false;
alone = true;
with(obj_unit) {
    if(_faction == me._faction && !dead && _jobclass != class_mirrorimage && id != me.id) {
        alone = false;
        if(_health / _maxhealth < me._offense_panic && point_distance(x, y, me.x, me.y) < me._sightdistance) panic = true;
    }
}
if(me._health / me._maxhealth < _offense_panic) panic = true;
if(_manatype_mana < _manatype_maxmana * _offense_min_mana) panic = true;

if(_smite_casting) {
    d = 999999;
    if(units_exists(_smite_target)) {
        if(!_smite_target.dead && !_smite_target._polymorphed) d = point_distance(x, y, _smite_target.x, _smite_target.y);
    }
    if(panic || d > _smite_range || _manatype_mana < _smite_manacost) {
        _smite_casting = false;
        _attackcastwait = 0;
        _attackcasttime = _normal_attackcasttime;
        return false;
    }
    _destx = x;
    _desty = y;
    _direction = point_direction(x, y, _smite_target.x, _smite_target.y);
    _dir = deg_to_dir(_direction);
    image_single = _dir * 4;
    _attackcastwait += 1;
    if(_attackcastwait >= _attackcasttime) {
        create_text_effect(x, y, c_yellow, "-smite-");
        unit_damage(_smite_target, c_yellow, _smite_amount);
        fx_spell(_smite_target, "smite");
        unit_mana(id, -_smite_manacost);
        _smite_casting = false;
        _attackcastwait = 0;
        _attackcasttime = _normal_attackcasttime;
    }
    return true;
}
if(panic) return false;

// Nearest enemy that isn't sheeped (or hiding)
best = -1;
bestd = 999999;
with(obj_unit) {
    if(_faction != me._faction && !dead && !_polymorphed && !_stealthed) {
        d = point_distance(x, y, me.x, me.y);
        if(d < bestd && d < me._sightdistance) {
            bestd = d;
            best = id;
        }
    }
}
if(best == -1) return false;

if(bestd >= _smite_range) {
    if(!alone) return false; // let the fighters go first; stay with the group
    // Last one standing: walk up to the enemy
    _direction = point_direction(x, y, best.x, best.y);
    _dir = deg_to_dir(_direction);
    _destx = round(x + cos(degtorad(_direction)) * _movespeed);
    _desty = round(y - sin(degtorad(_direction)) * _movespeed);
    _subindex += 0.1;
    move_towards_point_ext(_destx, _desty, _movespeed);
    image_single = _dir * 4 + floor(_subindex mod 4);
    return true;
}

// Healer Special Ability: Shadow Word: Pain (instant)
if(_swp_timer <= 0 && _manatype_mana >= _swp_manacost) {
    _swp_target = best;
    _swp_timer = _swp_duration;
    unit_mana(id, -_swp_manacost);
    create_text_effect(best.x, best.y, c_purple, "-shadow word: pain-");
    fx_spell(best, "shadow word: pain");
}

// Healer Special Ability: Smite
if(_manatype_mana >= _smite_manacost) {
    _smite_target = best;
    _smite_casting = true;
    _attackcastwait = 1;
    _attackcasttime = _smite_casttime;
    _destx = x;
    _desty = y;
    return true;
}
return false;
