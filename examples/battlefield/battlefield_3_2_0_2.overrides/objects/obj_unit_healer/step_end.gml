if(global.toggle_pause) exit;

// Decrement Cooldowns
// None of the Healer abilities have a cooldown

// (gm-revive overrides) Shadow Word: Pain ticks once a second; paused while the target is sheeped
// so the Healer never breaks its own side's Polymorph
if(_swp_timer > 0) {
    if(!units_exists(_swp_target)) _swp_timer = 0;
    else if(_swp_target.dead) _swp_timer = 0;
    else if(!_swp_target._polymorphed) {
        _swp_timer -= 1;
        if(_swp_timer mod room_speed == 0) unit_damage(_swp_target, c_purple, _swp_tick_amount);
    }
}

if(dead || _stunned) exit;
if(_polymorphed) {
    // Reset all Unique spell cooldowns
    _attackcastwait = 0;
    _attackcasttime = _normal_attackcasttime;
    _flashheal_casting = false;
    _greaterheal_casting = false;
    _smite_casting = false;
    _poh_casting = false;
    event_inherited();
    exit;
}

if(global.cutscene_active) exit;

// (gm-revive overrides) Healer Special Ability: Prayer of Healing
if(healer_prayer()) {
    event_inherited();
    depth = -y;
    exit;
}

var dist, dir, maxhp, maxdist, hp, me;
maxhp = 0;
// Find a friendly unit in range (preferably one that is taking damage)
me = id;
if(_attackcastwait <= 0) {
    maxhp = 0;
    maxdist = 9999;
    with(obj_unit) {
        if(_faction == other._faction && _jobclass != class_mirrorimage) {
            hp = _maxhealth - _health;
            if(id == other.id) {
                if(hp > 20 && _health < _maxhealth) {
                    maxhp = hp;
                    other._target = id;
                    break;
                }
                continue;
            }
            
            dist = point_distance(x, y, other.x, other.y);
            if(dist < _sightdistance) {
                calculate_incoming_effects(id, other.id);
                
                hp += global.calc_damage;
                hp -= global.calc_healing;
                
                if(hp > maxhp) {
                    maxhp = hp;
                    maxdist = dist;
                    other._target = id;
                    continue;
                }
            }
        }
    }
}

// (gm-revive overrides) Smite / Shadow Word: Pain when nobody needs healing
if(_smite_casting || (_attackcastwait <= 0 && !_poh_casting && maxhp < _offense_threshold)) {
    if(healer_offense()) {
        event_inherited();
        depth = -y;
        exit;
    }
}

if(units_exists(_target)) {
    // Yes, we have a target
    dist = point_distance(x, y, _target.x, _target.y);
    if(dist >= _attackrange / 1.25) {
        // Move into our attack range
        _attackcastwait = 0;
        _direction = point_direction(x, y, _target.x, _target.y);
        _dir = deg_to_dir(_direction);
        _destx = round(x + cos(degtorad(_direction)) * _movespeed);
        _desty = round(y - sin(degtorad(_direction)) * _movespeed);
        
        _subindex += 0.1;
        move_towards_point_ext(_destx, _desty, _movespeed);
        image_single = _dir * 4 + floor(_subindex mod 4);
        depth = -y;
        exit;
    }
    else {
        // We are in casting range
        _destx = x;
        _desty = y;
        hp = _target._maxhealth - _target._health;
        if(hp >= 1) {
            if(hp < 50) {
                // Flash Heal!
                _attackcasttime = _flashheal_casttime;
                _flashheal_casting = true;
                if(_greaterheal_casting) {
                    _attackcastwait = 0;
                    _greaterheal_casting = false;
                }
            }
            else {
                // Greater Heal!
                _attackcasttime = _greaterheal_casttime;
                _greaterheal_casting = true;
                if(_flashheal_casting) {
                    _attackcastwait = 0;
                    _flashheal_casting = false;
                }
            }
        }
        else {
            _greaterheal_casting = false;
            _flashheal_casting = false;
            _attackcastwait = 0;
        }
        
        if(_target._weakenedsoul <= 0 && _target._absorbamount < 110) {
            // Healer Special Ability: Power Word: Shield
            _target._absorbmax = max(120, _target._absorbamount);
            _target._absorbamount = min(120, _target._absorbmax);
            _target._weakenedsoul = room_speed * 15;
        }
        else if(_target._renewtimer <= 0 && _manatype_mana >= _renew_manacost) {
            // Healer Special Ability: Renew
            _target._renewtimer = room_speed * 15;
            unit_mana(id, -_renew_manacost);
        }
        else if(_flashheal_casting && _manatype_mana >= _flashheal_manacost) {
            // Healer Special Ability: Flash Heal
            _attackcastwait += 1;
            if(_attackcastwait >= _flashheal_casttime) {
                // Flash Heal Effect
                unit_heal(_target, _flashheal_amount);
                unit_mana(id, -_flashheal_manacost);
                _attackcastwait = 0;
                _attackcasttime = _normal_attackcasttime;
                _flashheal_casting = false;
                _target = -1;
            }
        }
        else if(_greaterheal_casting && _manatype_mana >= _greaterheal_manacost) {
            // Healer Special Ability: Greater Heal
            _attackcastwait += 1;
            if(_attackcastwait >= _greaterheal_casttime) {
                // Greater Heal Effect
                unit_heal(_target, _greaterheal_amount);
                unit_mana(id, -_greaterheal_manacost);
                _attackcastwait = 0;
                _attackcasttime = _normal_attackcasttime;
                _greaterheal_casting = false;
                _target = -1;
            }
        }
    }
}
else {
    _attackcastwait = 0;
    if(!units_exists(_target)) {
        // Still nothing? Just go somewhere that's not here!
        if(_destx == x && _desty == y) {
            _pause -= 1;
            if(_pause <= 0) {
                // Go searching for something to kill on our own
                _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
                _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
                _pause = room_speed * (1 + random(4)); // Pause for a few seconds
            }
            else _message = "*sigh*";
        } 
    }
}

// Default actions
event_inherited();
depth = -y;
