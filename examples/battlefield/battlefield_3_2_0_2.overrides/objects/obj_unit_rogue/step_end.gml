if(global.toggle_pause) exit;

// (gm-revive overrides) Evasion wears off even while stunned
if(_evasion_timer > 0) {
    _evasion_timer -= 1;
    if(_evasion_timer <= 0) {
        _damagereduction -= _evasion_reduction;
        create_text_effect(x, y, c_white, "-evasion faded-");
    }
}

if(dead || _stunned) exit;

// Decrement Cooldowns
_kick_cooldown -= 1;
_kidneyshot_cooldown -= 1;
_evasion_cooldown -= 1;
_mainhand_cooldown -= 1;
_offhand_cooldown -= 1;
_stealth_cooldown -= 1;
_vanish_cooldown -= 1;
_vanish_duration -= 1;
_stealth_cooldown -= 1;
_sprint_cooldown -= 1;
_sprint_duration -= 1;
_bandage_cooldown -= 1;
_sinisterstrike_cooldown -= 1;
_slice_and_dice_duration -= 1;
_adrenaline_rush_cooldown -= 1;
_adrenaline_rush_duration -= 1;

// Slice and Dice wear off?
if(_slice_and_dice_duration <= 0 && _slice_and_dice_active) {
    _mainhand_attackspeed = _mainhand_normal_attackspeed;
    _offhand_attackspeed = _offhand_normal_attackspeed;
    _slice_and_dice_active = false;
}

// Vanished?
if(_vanish_active) {
    _stealthed_visibility = 0;
    _stealthed = true;
    if(_vanish_duration <= 0) _vanish_active = false;
}
else {
    _stealthed_visibility += ((range_melee * 1.25) - _stealthed_visibility) / 10;
}

// Regenerate Energy
_energy_rate = _normal_energy_rate;

// Adrenaline Rush wearing off?
if(_adrenaline_rush_active && !_casting) {
    _energy_rate *= _adrenaline_rush_rate;
    if(_adrenaline_rush_duration <= 0) {
        _adrenaline_rush_active = false;
        _attackcastwait = 0;
    }
    else {
        _attackcastwait = _adrenaline_rush_duration;
        _attackcasttime = _adrenaline_rush_duration_time;
    }
}

_manatype_energy = min(_manatype_maxenergy, _manatype_energy + _energy_rate);

// Calculate correct movement speed
_movespeed = _normal_movespeed;
if(_sprint_active) _movespeed *= 2;
if(_stealthed) _movespeed *= 0.5;

if(_polymorphed) exit;

if(_casting) {
    // Rogue Special Ability: Bandage
    // The Rogue uses his First Aid skill to mend wounds.
    // Heals for approximately 85 health over 6 seconds.
    // Must be stealthed to use this ability.
    if(_bandage_casting) {
        _attackcasttime = _bandage_duration;
        if(_attackcastwait mod room_speed == 0) {
            unit_heal(_target, _bandage_amount / (_bandage_duration / room_speed));
        }
        _attackcastwait -= 1;
        if(_attackcastwait < 0 || _health >= _maxhealth) {
            _bandage_casting = false;
            _attackcastwait = 0;
            _casting = false;
            _target = -1;
        }
    }
    exit;
}

if(global.cutscene_active) exit;

var dist, priority, maxdist, maxhp, gtfo;
dist = 0;
maxdist = 9999;
priority = 999;
maxhp = 9999;
gtfo = false;

// Generate potential lists of units
unit_lists_populate();

var allies, enemies, healer_count, target_amount, i, index;
allies = ds_list_size(_allylist);
enemies = ds_list_size(_enemylist);
healer_count = ds_list_size(_healerlist);
target_amount = ds_list_size(_targetlist);

// (added by gm-revive overrides) A stealthed Rogue only attacks when its side has the numbers, so one
// whose team is gone used to hide forever and the battle never ended. A Rogue that is the last of its
// side, or has been waiting in stealth for 12 seconds, stops waiting for backup. Once it's back to
// full health (after Vanish and a Bandage, say) it goes straight back in, even while Vanish lasts.
// (_stealth_wait starts at 0: the project treats uninitialised variables as 0)
var alone, brave, healthy;
alone = true;
with(obj_unit) {
    if(_faction == other._faction && id != other.id && !dead && _jobclass != class_mirrorimage) alone = false;
}
if(_stealthed && !_vanish_active) _stealth_wait += 1;
else _stealth_wait = 0;
healthy = _health >= _maxhealth * 0.95;
brave = alone || _stealth_wait > room_speed * 12 || healthy;

// Does a target exist?
if(units_exists(_target) && ds_list_find_index(_enemylist, _target) >= 0) {
    dist = unit_dist(id, _target);
    if(_target._stealthed && dist > _target._stealthed_visibility) { _target = -1; exit; }
    if(dist > _attackrange * 2) {
        // Is Sprint off cooldown?
        if(_sprint_cooldown <= 0) {
            // Rogue Special Ability: Sprint
            // The Rogue calls upon untold speed in order to pursue or escape his enemies
            _sprint_active = true;
            create_text_effect(x, y, c_white, "-sprint-");
            _sprint_duration = _sprint_duration_time;
            _sprint_cooldown = _sprint_cooldown_time;
            _movespeed *= 2;
        }
    }
    
    if(!_stealthed) {
        // I can destroy things! HAHAHAHA!
        if(dist < _attackrange) {
            _destx = x;
            _desty = y;
            
            // Rogue Special Ability: Kick (gm-revive overrides)
            // Interrupt the target, or anyone else within reach, in the middle of a spell
            if(_kick_cooldown <= 0 && _manatype_energy >= _kick_cost) {
                var kt;
                kt = -1;
                if(unit_is_casting(_target)) kt = _target;
                else {
                    for(i = 0; i < enemies; i += 1) {
                        index = ds_list_find_value(_enemylist, i);
                        if(unit_dist(id, index) < _attackrange && unit_is_casting(index)) {
                            kt = index;
                            break;
                        }
                    }
                }
                if(kt != -1) {
                    create_text_effect(x, y, c_white, "-kick-");
                    unit_interrupt(kt, _kick_lockout);
                    fx_spell(kt, "kick");
                    unit_mana(id, -_kick_cost);
                    _kick_cooldown = _kick_cooldown_time;
                }
            }
            
            // Attack them!
            if(_mainhand_cooldown <= 0) {
                // Attack with the main hand weapon
                unit_damage(_target, c_white, _mainhand_damage);
                _mainhand_cooldown = _mainhand_attackspeed;
            }
            if(_offhand_cooldown <= 0) {
                // Attack with the off hand weapon
                unit_damage(_target, c_white, _offhand_damage);
                _offhand_cooldown = _offhand_attackspeed;
            }
            
            if(_manatype_energy <= (_manatype_maxenergy / 1.5) && _adrenaline_rush_cooldown <= 0) {
                // Rogue Special Ability: Adrenaline Rush
                // Increases Energy Regeneration Rate by 100% for 15 seconds.
                create_text_effect(x, y, c_white, "-adrenaline rush-");
                _adrenaline_rush_duration = _adrenaline_rush_duration_time;
                _adrenaline_rush_cooldown = _adrenaline_rush_cooldown_time;
                _attackcastwait = _adrenaline_rush_duration;
                _attackcasttime = _adrenaline_rush_duration_time;
                _adrenaline_rush_active = true;
            }
            
            // Finishing Moves
            if(!_slice_and_dice_active && _manatype_energy >= _slice_and_dice_cost && _combo_points > 0) {
                // Rogue Special Ability: Slice and Dice
                // A Finishing Move that uses all of the Combo Points to increase attack speed by 40%.
                _slice_and_dice_active = true;
                _slice_and_dice_duration = room_speed * (_slice_and_dice_duration_cp * _combo_points);
                create_text_effect(x, y, c_white, "-slice and dice-");
                unit_mana(id, -_slice_and_dice_cost);
                _combo_points = 0;
                _mainhand_attackspeed *= (1 - _slice_and_dice_modifier);
                _offhand_attackspeed *= (1 - _slice_and_dice_modifier);
            }
            else if(_kidneyshot_cooldown <= 0 && _manatype_energy >= _kidneyshot_cost && _target == _combo_target && _combo_points >= _kidneyshot_min_points && !_target._stunned && !_target._stunimmune
                    && (_target._jobclass == class_healer || _target._jobclass == class_shaman || _target._jobclass == class_paladin || _target._jobclass == class_caster
                        || (_target._jobclass == class_druid && _target._shapeshift_form == druid_form_normal) || unit_is_casting(_target))) {
                // Rogue Special Ability: Kidney Shot (gm-revive overrides)
                // Finishing move: lock down a healer or caster for 1 second plus 1 per combo point
                if(unit_stun(_target, room_speed * (1 + _combo_points))) {
                    create_text_effect(x, y, c_white, "-kidney shot-");
                    unit_mana(id, -_kidneyshot_cost);
                    _combo_points = 0;
                    _kidneyshot_cooldown = _kidneyshot_cooldown_time;
                }
            }
            else if(_manatype_energy >= _eviscerate_cost && (_target == _combo_target && (_combo_points == 5 || _target._health < _eviscerate_damage * _combo_points))) {
                // Rogue Special Ability: Eviscerate
                // A Finishing Move that uses all of the Combo Points to do massive physical damage to a target
                create_text_effect(x, y, c_white, "-eviscerate-");
                unit_damage(_target, c_yellow, _eviscerate_damage * _combo_points);
                unit_mana(id, -_eviscerate_cost);
                _combo_points = 0;
            }
            
            // Combos
            if(_manatype_energy >= _sinisterstrike_cost && (_combo_points < 5 || _target != _combo_target)) {
                // Rogue Special Ability: Sinister Strike
                // Every GCD, the Rogue can use his malice to slice up his enemy.
                // Awards one combo point to the target at the cost of 35 Energy.
                if(_sinisterstrike_cooldown <= 0) {
                    if(_target != _combo_target) {
                        _combo_target = _target;
                        _combo_points = 0;
                    }
                    _combo_points += 1;
                    unit_damage(_target, c_yellow, _sinisterstrike_damage);
                    fx_spell(_target, "sinister strike");
                    unit_mana(id, -_sinisterstrike_cost);
                    _sinisterstrike_cooldown = _sinisterstrike_cooldown_time;
                }
            }
        }
        else {
            // Move closer
            /*if(_stealth_cooldown <= 0 && !_stealthed && !_sprint_active) {
                // Rogue Special Ability: Stealth
                // The Rogue uses the shadows to avoid detection from his enemies.
                // In this state, movement speed is reduced by 50%
                _stealthed = true;
                _stealth_cooldown = _stealth_cooldown_time;
                
                // Clear all focusses on me!
                with(obj_unit) {
                    if(_faction != other._faction) {
                        if(_target == other.id) _target = -1;
                    }
                }
            }*/
            
            dir = point_direction(x, y, _target.x, _target.y);
            _destx = round(x + cos(degtorad(dir)) * _movespeed);
            _desty = round(y - sin(degtorad(dir)) * _movespeed);
        }
        
        // Rogue Special Ability: Evasion (gm-revive overrides)
        // Halve incoming damage for a while when something is beating on me in melee and I'm hurt
        if(_evasion_cooldown <= 0 && _evasion_timer <= 0 && _health < _maxhealth * _evasion_threshold) {
            var mt;
            mt = false;
            for(i = 0; i < target_amount; i += 1) {
                index = ds_list_find_value(_targetlist, i);
                if(unit_dist(id, index) <= range_melee + 8) mt = true;
            }
            if(mt) {
                _evasion_timer = _evasion_duration;
                _evasion_cooldown = _evasion_cooldown_time;
                _damagereduction += _evasion_reduction;
                create_text_effect(x, y, c_white, "-evasion-");
                with(instance_create(x, y, obj_fx_aura)) { _master = other.id; _kind = 2; }
            }
        }
        
        // Am I damaged? Should I GTFO?
        if(_target._jobclass == class_warrior) {
            if(_target._laststand_used && _target._target == id) gtfo = true;
        }
        if(_health < (_maxhealth * .4) || gtfo) {
            // Can I GTFO?
            if(_vanish_cooldown <= 0) {
                // Rogue Special Ability: Vanish
                // The Rogue enters an improved stealth effect for 10 seconds, after which he will remain stealthed until the effect is over
                // The Rogue becomes oblivious to all non-AOE damaging effects and targetting
                _vanish_active = true;
                _vanish_cooldown = _vanish_cooldown_time;
                _vanish_duration = _vanish_duration_time;
                _stealthed_visibility = 0;
                create_text_effect(x, y, c_white, "-vanish-");
                _stealthed = true;
                _stealth_cooldown = _stealth_cooldown_time;
                
                repeat(5) {
                    with(instance_create(x, y, obj_evocation_effect)) image_blend = c_black;
                }
                
                // Clear all focusses on me!
                for(i = 0;i < target_amount; i += 1) {
                    with(ds_list_find_value(_targetlist, i)) _target = -1;
                }
            }
        }
    }
    else {
        // I'd best STFU before I'm discovered! SHHHH!
        
        // Rogue Special Ability: Bandage
        // The Rogue uses his First Aid skill to mend wounds.
        // Heals for approximately 85 health over 6 seconds.
        // Must be stealthed to use this ability.
        if(_bandage_cooldown <= 0 && (_health < (_maxhealth - 2))) {
            _bandage_casting = true;
            _adrenaline_rush_active = false;
            _bandage_cooldown = _bandage_cooldown_time;
            _attackcastwait = _bandage_duration;
            _casting = true;
            _target = id;
            exit;
        }
        
        for(i = 0;i < enemies;i += 1) {
            with(ds_list_find_value(_enemylist, i)) {
                dist = unit_dist(id, other);
                if(dist < maxdist) {
                    maxdist = dist;
                    other._target = id;
                }
            }
        }
        
        if(allies >= enemies || brave) {
            dist = unit_dist(id, _target);
            if(dist < _attackrange) {
                // Ambush the bastard!
                if(_health > (_maxhealth * .4) || !_vanish_active) {
                    // Rogue Special Ability: Cheap Shot (gm-revive overrides)
                    // Open with a 3 second stun (and 2 combo points), then Ambush if there's Energy left
                    if(_manatype_energy >= _cheapshot_cost && !_target._stunned && !_target._stunimmune) {
                        if(unit_stun(_target, _cheapshot_duration)) {
                            create_text_effect(x, y, c_white, "-cheap shot-");
                            unit_mana(id, -_cheapshot_cost);
                            if(_combo_target != _target) {
                                _combo_target = _target;
                                _combo_points = 0;
                            }
                            _combo_points = min(5, _combo_points + _cheapshot_combo_points);
                        }
                    }
                    // Rogue Special Ability: Ambush
                    if(_manatype_energy > _ambush_cost) {
                        create_text_effect(x, y, c_white, "-ambush-");
                        unit_damage(_target, c_yellow, (_mainhand_damage + _offhand_damage) * _ambush_rate);
                        unit_mana(id, -_ambush_cost);
                        if(_combo_target == _target) {
                            _combo_points = min(5, _combo_points + _ambush_combo_points);
                        }
                        else {
                            _combo_points = _ambush_combo_points;
                            _combo_target = _target;
                        }
                    }
                    _stealthed = false;
                }
                else {
                    dir = point_direction(_target.x, _target.y, x, y);
                    _destx = round(x + cos(degtorad(dir)) * _movespeed);
                    _desty = round(y - sin(degtorad(dir)) * _movespeed);
                }
            }
            else {
                // Move closer
                if((!_vanish_active || healthy) && (enemies <= 1 || allies > 1 || brave)) {
                    dir = point_direction(x, y, _target.x, _target.y);
                    _destx = round(x + cos(degtorad(dir)) * _movespeed);
                    _desty = round(y - sin(degtorad(dir)) * _movespeed);
                }
                else if(dist < _target._sightdistance * .75) {
                    dir = point_direction(_target.x, _target.y, x, y);
                    _destx = round(x + cos(degtorad(dir)) * _movespeed);
                    _desty = round(y - sin(degtorad(dir)) * _movespeed);
                }
                else _target = -1;
            }
        }
        else if(dist < _target._sightdistance * .75) {
            dir = point_direction(_target.x, _target.y, x, y);
            _destx = round(x + cos(degtorad(dir)) * _movespeed);
            _desty = round(y - sin(degtorad(dir)) * _movespeed);
        }
        else _target = -1;
    }
}
else {
    // Find a target, preferably one that heals people
    if(_stealth_cooldown <= 0 && !_stealthed) {
        // Rogue Special Ability: Stealth
        // The Rogue uses the shadows to avoid detection from his enemies.
        // In this state, movement speed is reduced by 50%
        _stealthed = true;
        _stealth_cooldown = _stealth_cooldown_time;
        
        // Clear all focusses on me!
        for(i = 0;i < target_amount; i += 1) {
            (ds_list_find_value(_targetlist, i))._target = -1;
        }
    }
    
    for(i = 0;i < enemies; i += 1;) {
        with(ds_list_find_value(_enemylist, i)) {
            dist = unit_dist(id, other);
            if(!_polymorphed) {
                // He's within my Line of Sight
                if(_jobclass == class_healer && (priority > -1 || (priority == -1 && dist < maxdist))) {
                    priority = -1;
                    maxdist = dist;
                    maxhp = _health;
                    other._target = id;
                    continue;
                }
                else if(_jobclass == class_shaman && (priority > 0 || (priority == 0 && dist < maxdist))) {
                    priority = 0;
                    maxdist = dist;
                    maxhp = _health;
                    other._target = id;
                    continue;
                }
                else if(_jobclass == class_caster && (priority > 1 || (priority == 1 && dist < maxdist))) {
                    priority = 1;
                    maxdist = dist;
                    maxhp = _health;
                    other._target = id;
                    continue;
                }
                else if(_jobclass == class_rogue && (priority > 2 || (priority == 2 && dist < maxdist))) {
                    priority = 2;
                    maxdist = dist;
                    maxhp = _health;
                    other._target = id;
                    continue;
                }
                else if(priority > 3 || (priority == 3 && dist < maxdist)) {
                    priority = 3;
                    maxdist = dist;
                    maxhp = _health;
                    other._target = id;
                    continue;
                }
                
                if(_health < maxhp && priority >= 0.5 && _jobclass != class_mirrorimage) {
                    priority = 0.5;
                    maxhp = _health;
                    other._target = id;
                    continue;
                }  
            }
        }
    }
    
    // A target hasn't been found!
    if(!units_exists(_target)) {
        _message = "...";
        
        // We need to find a target somehow...
        // Anyone moving towards something within my sight?
        for(i = 0;i < allies;i += 1) {
            with(ds_list_find_value(_allylist, i)) {
                if(units_exists(_target) && ds_list_find_index(other._enemylist, _target) >= 0) {
                    if(_destx != x || _desty != y) {
                        other._destx = _destx;
                        other._desty = _desty;
                        break;
                    }
                }
            }
        }
        
        // All else fails...
        if(_destx == x && _desty == y) {
            // Go searching for something to kill on our own
            _pause -= 1;
            if(_pause <= 0) {
                // Go searching for something to kill on our own
                _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
                _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
                _pause = room_speed * (1 + random(4)); // Pause for a few seconds
            }
        }
    }
}

event_inherited();

// Sprinting?
if(_sprint_active) {
    create_sprint_effect(x, y, xprevious, yprevious);
    if(_sprint_duration <= 0) _sprint_active = false;
}

