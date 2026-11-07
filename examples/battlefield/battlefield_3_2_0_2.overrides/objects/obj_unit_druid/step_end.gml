if(global.toggle_pause) exit;

// Decrement Cooldowns
_shapeshift_cooldown -= 1;
_regrowth_cooldown -= 1;
_innervate_cooldown -= 1;

_swipe_cooldown -= 1;
_ironskin_cooldown -= 1;
_survivalinstincts_cooldown -= 1;
_growl_cooldown -= 1;
_bite_cooldown -= 1;

// A dead Druid takes its effects with it
if(dead) {
    druid_release();
    exit;
}

// Running effects: Rake bleed (ticks once a second)
if(_rake_timer > 0) {
    _rake_timer -= 1;
    if(!units_exists(_rake_target)) _rake_timer = 0;
    else if(_rake_target.dead) _rake_timer = 0;
    else if(_rake_timer mod room_speed == 0) unit_damage(_rake_target, c_red, _rake_tick_damage);
    if(_rake_timer <= 0) _rake_target = -1;
}

// Running effects: Ironskin
if(_ironskin_active) {
    _ironskin_duration -= 1;
    if(_ironskin_duration <= 0) {
        _ironskin_active = false;
        _damagereduction -= _ironskin_damagereduction;
        create_text_effect(x, y, c_yellow, "-ironskin faded-");
    }
}

// Running effects: Survival Instincts
if(_survivalinstincts_active) {
    _survivalinstincts_duration -= 1;
    if(_survivalinstincts_duration <= 0) {
        _survivalinstincts_active = false;
        _maxhealth -= _survivalinstincts_health;
        _health = max(1, min(_maxhealth, _health - _survivalinstincts_health));
        _survivalinstincts_health = 0;
        create_text_effect(x, y, c_yellow, "-survival instincts faded-");
    }
}

if(_stunned) exit;
if(_polymorphed) {
    // Reset all Unique spell cooldowns
    _casting = false;
    _attackcastwait = 0;
    
    // Bears don't enjoy being polymorphed too much. It fills them with rage!
    // A Bear will game 0.05% rage for every tick (60 ticks per second) that they are polymorphed
    if(_shapeshift_form == druid_form_bear) unit_mana(id, 0.05);
    
    event_inherited();
    exit;
}

if(global.cutscene_active) {
    _destx = x;
    _desty = y;
    event_inherited();
    exit;
}

// Generate potential lists of units
unit_lists_populate();

var allies, enemies, healer_count, target_amount, i, j, index;
allies = ds_list_size(_allylist);
enemies = ds_list_size(_enemylist);
healer_count = ds_list_size(_healerlist);
target_amount = ds_list_size(_targetlist);

// How is the fight going? (added) The weakest ally in sight, and how many healers there are besides me
var weakest, w, other_healers;
weakest = 1;
for(i = 0; i < allies; i += 1) {
    index = ds_list_find_value(_allylist, i);
    if(index == id) continue;
    w = index._health / index._maxhealth;
    if(w < weakest) weakest = w;
}
other_healers = healer_count;
if(ds_list_find_index(_healerlist, id) != -1) other_healers -= 1;

if(_shapeshift_form == druid_form_normal) {
    // Perform the tasks of a healer, otherwise transform back to kitty (or bear if being attacked)
    if(!_casting) {
        _target = -1;
        _attackcastwait = 0;
        _nourish_casting = false;
        
        if(instance_exists(obj_boss) && _shapeshift_form != druid_form_bear && (allies > 1 || _regrowth_timer > 0)) {
            with(obj_boss) {
                if(_target == other.id) {
                    unit_druid_shapeshift(other.id, druid_form_bear);
                    exit;
                } 
            }
        }
        
        // Pick a task to perform, then set the _casting flag if chosen
        //////////////////////////////////
        // Druid Normal Form Abilities
        //////////////////////////////////
        var lowest, lowesthp, hp, h, c;
        lowest = -1; lowesthp = 1;
        for(i = 0;i < allies; i += 1;) {
            index = ds_list_find_value(_allylist, i);
            hp = (index._health / index._maxhealth); c = 0;
            if(index._regrowth_timer < 0 && _regrowth_cooldown < 0 && _manatype_mana >= _regrowth_manacost) {
                // Druid Special Ability: Regrowth
                // Heals the druid's target for 150 damage over 8 seconds.
                index._regrowth_timer = _regrowth_healovertime_time * room_speed;
                index._regrowth_timer_seconds = _regrowth_healovertime_time;
                index._regrowth_timer_amount = _regrowth_healovertime;
                _regrowth_cooldown = _regrowth_cooldown_time;
                unit_mana(id, -_regrowth_manacost);
            }
            
            if(index._manatype == manatype_mana && _innervate_cooldown <= 0) {
                if(index._innervating_timer < 0 && (index._manatype_mana / index._manatype_maxmana) < 0.05) {
                    // Less than 5% mana, let's Innervate them
                    // Druid Special Ability: Innervate
                    // Restores mana equal to the Druid's maximum mana to a friendly target over 12 seconds.
                    _innervate_cooldown = _innervate_cooldown_time;
                    create_text_effect(x, y, c_white, "-innervate-");
                    create_text_effect(index.x, index.y, c_white, "-innervated-");
                    index._innervating_timer = room_speed * 12;
                    index._innervating_seconds = 12;
                    index._innervating_amount = _manatype_maxmana;
                }
            }
            
            if(hp < lowesthp) {
                // Check other healer targets
                for(j = 0;j < healer_count; j += 1;) {
                    h = ds_list_find_value(_healerlist, j);
                    if(h != id && h._target == index) c += 1;
                }
                if(c == 0) {
                    lowesthp = hp;
                    lowest = index;
                }
            }
        }
        
        if(lowest != -1) {
            if(lowest._maxhealth - lowest._health > 30) {
                // Druid Special Ability: Nourish
                // Heals the druid's target for 80 damage and places an additional 40 healing over time on the targe for 6 seconds.
                // Recasting this ability will refresh the duration of the Heal Over Time effect
                if(_manatype_mana >= _nourish_manacost) {
                    _target = lowest;
                    _casting = true;
                    _nourish_casting = true;
                    _attackcasttime = _nourish_casttime;
                }
            }
        }                 
    }
    
    if(!_casting) {
        // No task was chosen, then use this free time to DPS
        // Druid Special Ability: Shapeshift
        // The druid transforms into an animal in order to better match the situation at hand.
        // Shift out when someone else can cover the healing and nobody is in trouble:
        // Bear if enemies are already on me, Cat otherwise
        if(_shapeshift_cooldown <= 0) {
            if((allies > 1 && healer_count > (allies * 0.5)) || (other_healers >= 1 && weakest > 0.7)) {
                if(target_amount > 0) unit_druid_shapeshift(id, druid_form_bear);
                else unit_druid_shapeshift(id, druid_form_kitty);
                exit;
            }
            else if(enemies > 0 && weakest > 0.8 && _health / _maxhealth > 0.8) {
                // Nobody needs healing right now, even with no other healer around: go help fight.
                // Bear when being attacked or fighting alone, Cat otherwise. Without this a lone Druid
                // stood in human form healing itself forever.
                if(target_amount > 0 || allies <= 1) unit_druid_shapeshift(id, druid_form_bear);
                else unit_druid_shapeshift(id, druid_form_kitty);
                exit;
            }
        }
        
        // Move into range of a water totem when able to.
        var priority, p_id, p_dist, dist;
        priority = 9999; p_id = -1; p_dist = 99999;
        with(obj_totem) {
            if(_faction == other._faction) {
                if(_totem_class == totem_class_water) {
                    dist = unit_dist(id, other);
                    if(_totem_id == totem_id_manatide) {
                        if(dist < p_dist) {
                            priority = 0;
                            p_id = id;
                            p_dist = dist;
                        }
                    }
                    else if(_totem_id == totem_id_manaspring) {
                        if(dist < p_dist && priority >= 1) {
                            priority = 1;
                            p_id = id;
                            p_dist = dist;
                        }
                    }
                    else if(_totem_id == totem_id_healingstream) {
                        if(dist < p_dist && priority >= 2) {
                            priority = 2;
                            p_id = id;
                            p_dist = dist;
                        }
                    }
                }
            }
        }
        
        if(p_id != -1 && p_dist > (range_totem - 32)) {
            _direction = point_direction(x, y, p_id.x, p_id.y);
            _dir = deg_to_dir(_direction);
            _destx = round(x + cos(degtorad(_direction)) * _movespeed);
            _desty = round(y - sin(degtorad(_direction)) * _movespeed);
            
            _subindex += 0.1;
            move_towards_point_ext(_destx, _desty, _movespeed);
            image_single = _dir * 4 + floor(_subindex mod 4);
            depth = -y;
            exit;
        }

        // (gm-revive overrides) Nothing to heal and no enemy in sight: follow an ally that is heading
        // somewhere, otherwise wander like the other classes. Human form used to just stand still.
        if(enemies == 0) {
            var fi, fu, following;
            following = false;
            for(fi = 0; fi < allies; fi += 1) {
                fu = ds_list_find_value(_allylist, fi);
                if(fu != id && fu._jobclass != class_healer && (fu._destx != fu.x || fu._desty != fu.y)) {
                    _destx = fu._destx;
                    _desty = fu._desty;
                    following = true;
                    break;
                }
            }
            if(!following && _destx == x && _desty == y) {
                _pause -= 1;
                if(_pause <= 0) {
                    _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
                    _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
                    _pause = room_speed * (1 + random(4));
                }
            }
        }
    }
    else {
        _destx = x;
        _desty = y;
        if(instance_exists(_target) && !_target.dead) {
            if(_nourish_casting) {
                // Druid Special Ability: Nourish
                // Heals the druid's target for 80 damage and places an additional 40 healing over time on the targe for 6 seconds.
                // Recasting this ability will refresh the duration of the Heal Over Time effect
                _attackcastwait += 1;
                _attackcasttime = _nourish_casttime;
                
                if(_attackcastwait >= _attackcasttime) {
                    // Cast Successful
                    unit_heal(_target, _nourish_amount);
                    heal_fx(_target, 3);
                    unit_mana(id, -_nourish_manacost);
                    _target._nourish_tick_timer = _nourish_healovertime_time * room_speed;
                    _target._nourish_tick_seconds = _nourish_healovertime_time;
                    _target._nourish_tick_amount = _nourish_healovertime;
                    _casting = false;
                    _target = -1;
                    exit;
                }
            }
        }
        else {
            _casting = false;
            _target = -1;
            exit;
        }
    }
}
else if(_shapeshift_form == druid_form_kitty) {
    // Perform the tasks of a dps, otherwise transform into bear if focussed or switch to normal < 75% health or if there are more than 1 member of the team and less than 1/3 of them are healers
    sprite_index = spr_druid_kitty;
    _attackrange = range_melee;
    _attackdamage = _kitty_attackdamage;
    _attackspeed = _kitty_attackspeed;
    _manatype_energy = min(_manatype_maxenergy, _manatype_energy + _kitty_energy_rate);

    // Druid Special Ability: Shapeshift
    // The druid transforms into an animal in order to better match the situation at hand.
    if(_shapeshift_cooldown <= 0) {
        // Verifty the situation
        // (gm-revive overrides) Bear only when it is really needed: two or more enemies on me, or one
        // and I'm getting low. It used to go Bear whenever anything targeted it, which in a team fight
        // meant spending two thirds of the battle tanking instead of doing damage.
        if(target_amount >= 2 || (target_amount > 0 && _health / _maxhealth < 0.6)) {
            unit_druid_shapeshift(id, druid_form_bear);
            exit;
        }
        else if(weakest < 0.6 || (other_healers == 0 && weakest < 0.8)) {
            // An ally is in trouble, or hurt with nobody else to heal them: back to normal form to heal
            unit_druid_shapeshift(id, druid_form_normal);
            exit;
        }
        else if(_health / _maxhealth < 0.5 && healer_count == 0) {
            // Nobody around to heal me: go back to normal form and heal myself
            unit_druid_shapeshift(id, druid_form_normal);
            exit;
        }
    }

    // Pick a target: casting Healers/Casters first, then the weakest enemy in sight
    var t, best, bestscore, sc;
    if(units_exists(_target)) {
        if(_target.dead || _target._faction == _faction || ds_list_find_index(_enemylist, _target) == -1) _target = -1;
    }
    if(_taunted_duration > 0 && units_exists(_taunted_by)) _target = _taunted_by;
    if(!units_exists(_target)) {
        best = -1;
        bestscore = 9999;
        for(i = 0; i < enemies; i += 1) {
            t = ds_list_find_value(_enemylist, i);
            sc = (t._health / t._maxhealth) * 10;
            if(t._jobclass == class_healer || t._jobclass == class_caster) sc -= 5;
            if(t._attackcastwait > 0) sc -= 5;
            if(t._polymorphed) sc += 50;
            sc += unit_dist(id, t) / 100;
            if(sc < bestscore) {
                bestscore = sc;
                best = t;
            }
        }
        _target = best;
    }

    if(units_exists(_target)) {
        var dist, dir;
        dist = unit_dist(id, _target);
        if(dist >= _attackrange) {
            dir = point_direction(_target.x, _target.y, x, y);
            _destx = round(_target.x + cos(degtorad(dir)) * (_attackrange - 1 + unit_hitbox(_target) + unit_hitbox(id)));
            _desty = round(_target.y - sin(degtorad(dir)) * (_attackrange - 1 + unit_hitbox(_target) + unit_hitbox(id)));
        }
        else {
            _destx = x;
            _desty = y;
            if(_target._health / _target._maxhealth < _bite_threshold && _bite_cooldown <= 0 && _manatype_energy >= 25) {
                // Druid Special Ability: Ferocious Bite
                class_strike_fx(_target, 2);
                create_text_effect(x, y, c_yellow, "-ferocious bite-");
                fx_spell(_target, "ferocious bite");
                unit_damage(_target, c_yellow, _bite_damage + _manatype_energy);
                _manatype_energy = 0;
                _bite_cooldown = _bite_cooldown_time;
            }
            else if(druid_swipe_targets() >= 2 && _swipe_cooldown <= 0 && _manatype_energy >= _swipe_manacost) {
                // Druid Special Ability: Swipe
                druid_swipe();
                _manatype_energy -= _swipe_manacost;
            }
            else if((_rake_timer <= 0 || _rake_target != _target) && _manatype_energy >= _rake_cost) {
                // Druid Special Ability: Rake
                create_text_effect(x, y, c_yellow, "-rake-");
                unit_damage(_target, c_red, _rake_damage);
                _rake_target = _target;
                _rake_timer = _rake_duration;
                _manatype_energy -= _rake_cost;
            }
            else if(_manatype_energy >= _shred_cost + 20) {
                // Druid Special Ability: Shred (keep a little Energy back for Rake and Bite)
                class_strike_fx(_target, 2);
                create_text_effect(x, y, c_yellow, "-shred-");
                unit_damage(_target, c_yellow, _attackdamage * _shred_multiplier);
                _manatype_energy -= _shred_cost;
            }
            else if(_attackcooldown <= 0) {
                unit_damage(_target, c_white, _attackdamage);
                _attackcooldown = _attackspeed;
            }
        }
    }
    else if(_destx == x && _desty == y) {
        _pause -= 1;
        if(_pause <= 0) {
            _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
            _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
            _pause = room_speed * (1 + random(4));
        }
    }
}
else if(_shapeshift_form == druid_form_bear) {
    // Perform the tasks of a tank, otherwise switch to kitty form if not focussed
    sprite_index = spr_druid_bear;
    _attackrange = range_melee;
    _attackdamage = _bear_attackdamage;
    _attackspeed = _bear_attackspeed;

    // If a Bear doesn't know who he wants to kill, he will instead start to lose rage
    if(_target == -1) unit_mana(id, -0.05);
    else unit_mana(id, 0.05);

    // Druid Special Ability: Ironskin
    // Reduces all damage by 40% for 6 seconds
    if(!_ironskin_active && _ironskin_cooldown <= 0 && _health / _maxhealth < _ironskin_threshold) {
        _ironskin_active = true;
        _ironskin_duration = _ironskin_duration_time;
        _ironskin_cooldown = _ironskin_cooldown_time;
        _damagereduction += _ironskin_damagereduction;
        create_text_effect(x, y, c_yellow, "-ironskin-");
    }

    // Druid Special Ability: Survival Instincts
    // Increases maximum health by 30% for 6 seconds.
    if(!_survivalinstincts_active && _survivalinstincts_cooldown <= 0 && _health / _maxhealth < _survivalinstincts_threshold) {
        _survivalinstincts_active = true;
        _survivalinstincts_duration = _survivalinstincts_duration_time;
        _survivalinstincts_cooldown = _survivalinstincts_cooldown_time;
        _survivalinstincts_health = round(_maxhealth * _survivalinstincts_addition);
        _maxhealth += _survivalinstincts_health;
        _health += _survivalinstincts_health;
        create_text_effect(x, y, c_yellow, "-survival instincts-");
    }

    // Druid Special Ability: Shapeshift
    // The druid transforms into an animal in order to better match the situation at hand.
    // (Not while Ironskin or Survival Instincts are running: those belong to the bear)
    if(_shapeshift_cooldown <= 0 && !_ironskin_active && !_survivalinstincts_active && other_healers == 0 && _health / _maxhealth < 0.3) {
        // Nearly dead with nobody to heal me and the defensives used up: drop out of bear to heal
        unit_druid_shapeshift(id, druid_form_normal);
        exit;
    }
    if(_shapeshift_cooldown <= 0 && !_ironskin_active && !_survivalinstincts_active) {
        // (gm-revive overrides) also back to Cat when it's down to one attacker and I'm healthy,
        // unless I'm fighting alone (then the Bear's toughness is what wins)
        if(target_amount <= 0 || (target_amount == 1 && allies > 1 && _health / _maxhealth > 0.85)) {
            if(other_healers >= 1 && weakest >= 0.5) {
                unit_druid_shapeshift(id, druid_form_kitty);
            }
            else unit_druid_shapeshift(id, druid_form_normal);
            exit;
        }
    }

    // Pick a target: whoever is hitting our Healers/Casters, then whoever is hitting me, then the nearest
    var t, best, bestscore, sc;
    if(units_exists(_target)) {
        if(_target.dead || _target._faction == _faction || ds_list_find_index(_enemylist, _target) == -1) _target = -1;
    }
    if(_taunted_duration > 0 && units_exists(_taunted_by)) _target = _taunted_by;
    best = -1;
    bestscore = 9999;
    for(i = 0; i < enemies; i += 1) {
        t = ds_list_find_value(_enemylist, i);
        if(t._polymorphed) continue;
        sc = unit_dist(id, t) / 100;
        if(units_exists(t._target)) {
            if(t._target != id && t._target._faction == _faction && (t._target._jobclass == class_healer || t._target._jobclass == class_caster)) sc -= 20;
            else if(t._target == id) sc -= 10;
        }
        if(sc < bestscore) {
            bestscore = sc;
            best = t;
        }
    }
    if(best != -1 && (!units_exists(_target) || bestscore <= -20)) _target = best;

    if(units_exists(_target)) {
        var dist, dir;
        dist = unit_dist(id, _target);

        // Druid Special Ability: Growl
        // Taunt an enemy that is attacking one of our Healers or Casters
        if(_growl_cooldown <= 0 && dist < range_shout && !_target._tauntimmune && units_exists(_target._target)) {
            if(_target._target != id && _target._target._faction == _faction) {
                create_text_effect(_target.x, _target.y, c_yellow, "-growl-");
                _target._taunted_by = id;
                _target._taunted_duration = room_speed * 4;
                _target._target = id;
                _growl_cooldown = _growl_cooldown_time;
            }
        }

        if(dist >= _attackrange) {
            dir = point_direction(_target.x, _target.y, x, y);
            _destx = round(_target.x + cos(degtorad(dir)) * (_attackrange - 1 + unit_hitbox(_target) + unit_hitbox(id)));
            _desty = round(_target.y - sin(degtorad(dir)) * (_attackrange - 1 + unit_hitbox(_target) + unit_hitbox(id)));
        }
        else {
            _destx = x;
            _desty = y;
            if(druid_swipe_targets() >= 2 && _swipe_cooldown <= 0 && _manatype_rage >= _swipe_manacost) {
                // Druid Special Ability: Swipe
                druid_swipe();
                unit_mana(id, -_swipe_manacost);
            }
            else if(_attackcooldown <= 0) {
                unit_damage(_target, c_white, _attackdamage);
                unit_mana(id, _bear_rage_per_hit);
                _attackcooldown = _attackspeed;
            }
        }
    }
    else if(_destx == x && _desty == y) {
        _pause -= 1;
        if(_pause <= 0) {
            _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
            _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
            _pause = room_speed * (1 + random(4));
        }
    }
}


event_inherited();
depth = -y;
