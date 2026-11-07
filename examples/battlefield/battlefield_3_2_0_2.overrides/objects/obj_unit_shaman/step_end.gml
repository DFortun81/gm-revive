if(global.toggle_pause) exit;

// Decrement Cooldowns
_attackcooldown -= 1;
_chainlightning_cooldown -= 1;
_shock_cooldown -= 1;
_windshear_cooldown -= 1;
_purge_cooldown -= 1;
_totem_fire_magma_cooldown -= 1;
_totem_wind_shear_cooldown -= 1;
_totem_water_manatide_cooldown -= 1;

if(dead || _stunned) exit;
if(_polymorphed) {
    // Reset all Unique spell cooldowns
    _attackcastwait = 0;
    _lightningbolt_casting = false;
    _chainlightning_casting = false;
    _healingwave_casting = false;
    _lesserhealingwave_casting = false;
    _chainheal_casting = false;
    event_inherited();
    exit;
}

if(global.cutscene_active) exit;

var dist, jdist, i, d, j, t, maxdist, maxhp, hp, ds, path, _id, dir;
maxhp = 0;

// Shaman Special Ability: Wind Shear (gm-revive overrides: defined in the create event but never cast)
// Instant, at range: interrupts an enemy in the middle of a spell and locks it out for 1 second.
// Usable while the Shaman is casting something itself.
if(_windshear_cooldown <= 0) {
    var ws, wsi, wsu;
    ws = -1;
    if(unit_is_casting(_target) && unit_dist(id, _target) < range_cast) ws = _target;
    else {
        with(obj_unit) {
            if(ws == -1 && _faction != other._faction && !dead && unit_dist(id, other) < range_cast) {
                if(unit_is_casting(id)) ws = id;
            }
        }
    }
    if(ws != -1) {
        create_text_effect(x, y, c_white, "-wind shear-");
        unit_interrupt(ws, room_speed);
        _windshear_cooldown = _windshear_cooldown_time;
    }
}

if(units_exists(_target)) {
    /////////////////////////////////////
    // Shaman Special Spell Class: Totem: Water Totem
    // Used forever, most useful (helpful) totem to a Shaman
    /////////////////////////////////////
    if(units_exists(_totem_water)) {
        if(point_distance(x, y, _totem_water.x, _totem_water.y) >= _totem_water._range) {
            if((_manatype_mana / _manatype_maxmana) > 0.25) create_totem(totem_class_water, totem_id_manaspring);
            else if(_totem_water_manatide_cooldown <= 0) create_totem(totem_class_water, totem_id_manatide);
            else create_totem(totem_class_water, totem_id_manaspring);
        }
        else if((_manatype_mana / _manatype_maxmana) <= 0.25 && _totem_water_manatide_cooldown <= 0) create_totem(totem_class_water, totem_id_manatide);
    }
    else create_totem(totem_class_water, totem_id_manaspring);
    
    if(units_exists(_totem_fire)) {
        if(point_distance(x, y, _totem_fire.x, _totem_fire.y) >= _totem_fire._range) {
            if(_totem_fire._totem_id != totem_id_magma) create_totem(totem_class_fire, totem_id_magma);
        }
    }
    else if(enemies_inrange(_faction, range_totem) > 0) create_totem(totem_class_fire, totem_id_magma);

    dist = unit_dist(id, _target);
    if(_target._faction != _faction) {
        // Damaging
        if(dist < range_cast) {
            _healingwave_casting = false;
            _lesserhealingwave_casting = false;
            _chainheal_casting = false;
            
            if(_attackcastwait <= 0) {
                if(_shock_cooldown <= 0 && _manatype_mana >= _shock_manacost) {
                    /////////////////////////////////////
                    // Shaman Special Spell Class: Shock
                    /////////////////////////////////////
                    if(_target._health <= _shock_frost_amount) {
                        // Shaman Special Ability: Frost Shock (Shock)
                        unit_damage(_target, c_yellow, _shock_frost_amount);
                        create_text_effect(x, y, c_white, "-frost shock-");
                        fx_spell(_target, "frost shock");
                    }
                    else {
                        // Make a buffs / debuffs list for each unit
                        // Check to see if the fire debuff is on the target or not before casting it
                        // Otherwise do the other one
                        // Shaman Special Ability: Flame Shock (Shock)
                        
                        // Shaman Special Ability: Earth Shock (Shock)
                        unit_damage(_target, c_yellow, _shock_earth_amount);
                        create_text_effect(x, y, c_white, "-earth shock-");
                        fx_spell(_target, "earth shock");
                    }
                    unit_mana(id, _shock_manacost);
                    _shock_cooldown = _shock_cooldown_time;
                }
                
                /////////////////////////////////////
                // Shaman Special Spell Class: Totem
                /////////////////////////////////////
                if(units_exists(_totem_earth)) {
                    if(point_distance(x, y, _totem_earth.x, _totem_earth.y) >= _totem_earth._range) {
                        create_totem(totem_class_earth, totem_id_strengthofearth);
                    }
                }
                else create_totem(totem_class_earth, totem_id_strengthofearth);
                
                if(units_exists(_totem_wind)) {
                    if(point_distance(x, y, _totem_wind.x, _totem_wind.y) >= _totem_wind._range) {
                        if(_totem_wind._totem_id != totem_id_windshear) create_totem(totem_class_wind, totem_id_windshear);
                    }
                }
                else create_totem(totem_class_wind, totem_id_windshear);
                
                // Determine which spell to cast
                t = _target;
                ds = ds_list_create();
                ds_list_add(ds, _target);
                
                // Chain to 2 additional targets
                for(i = 0;i < 2;i += 1) {
                    j = -1;
                    
                    maxdist = 9999;
                    with(obj_unit) {
                        if(_faction != other._faction) {
                            jdist = unit_dist(id, t);
                            if(jdist < range_totem && ds_list_find_index(ds, id) < 0 && (!_stealthed || (_stealthed && dist <= _stealthed_visibility))) {
                                if(jdist < maxdist || (jdist == maxdist && round(random(2)) == 0)) {
                                    maxdist = jdist;
                                    j = id;
                                    continue;
                                }
                            }
                        }
                    }
                    
                    if(j != -1) {
                        ds_list_add(ds, j);
                        t = j;
                    }
                    else break;
                }
                if(ds_list_size(ds) >= 2 && _manatype_mana >= _chainlightning_manacost) _chainlightning_casting = true;
                else if(_manatype_mana >= _lightningbolt_manacost) _lightningbolt_casting = true;
                ds_list_destroy(ds);
            }
            
            if(_lightningbolt_casting && _manatype_mana >= _lightningbolt_manacost) {
                // Shaman Special Ability: Lightning Bolt
                _attackcasttime = _lightningbolt_casttime;
                
                _attackcastwait += 1;
                if(_attackcastwait < _attackcasttime) {
                    _destx = x;
                    _desty = y;
                }
                else {
                    // Cast completed!
                    path = path_add();
                    dir = point_direction(x, y, _target.x, _target.y);
                    path_add_point(path, x + cos(degtorad(dir)) * 10, y - sin(degtorad(dir)) * 10, sprite_height / 2);
                    path_add_point(path, _target.x, _target.y, _target.sprite_height / 2);
                    fx_path_bolts(path, 0);
                    
                    unit_damage(_target, c_yellow, _lightningbolt_amount);
                    unit_mana(id, -_lightningbolt_manacost);
                    _target = -1;
                    _attackcastwait = 0;
                    _lightningbolt_casting = false;
                }
            }
            else if(_chainlightning_casting && _manatype_mana >= _chainlightning_manacost) {
                // Shaman Special Ability: Chain Lightning
                _attackcasttime = _chainlightning_casttime;
                
                _attackcastwait += 1;
                if(_attackcastwait < _attackcasttime) {
                    _destx = x;
                    _desty = y;
                }
                else {
                    // Cast completed!
                    t = _target;
                    d = _chainlightning_amount; // Damage from chain lightning gets progressively weaker the number of times it chains
                    ds = ds_list_create();
                    ds_list_add(ds, _target);
                    
                    // Chain to 2 additional targets
                    for(i = 0;i < 2;i += 1) {
                        j = -1;
                        
                        maxdist = 9999;
                        with(obj_unit) {
                            if(_faction != other._faction) {
                                jdist = unit_dist(id, t);
                                if(jdist < range_totem && ds_list_find_index(ds, id) < 0 && (!_stealthed || (_stealthed && dist <= _stealthed_visibility))) {
                                    if(jdist < maxdist || (jdist == maxdist && round(random(2)) == 0)) {
                                        maxdist = jdist;
                                        j = id;
                                        continue;
                                    }
                                }
                            }
                        }
                        
                        if(j != -1) {
                            ds_list_add(ds, j);
                            t = j;
                        }
                        else break;
                    }
                    
                    path = path_add();
                    path_set_closed(path, false);
                    dir = point_direction(x, y, _target.x, _target.y);
                    path_add_point(path, x + cos(degtorad(dir)) * 10, y - sin(degtorad(dir)) * 10, sprite_height / 2);
                    for(i = 0;i < ds_list_size(ds); i += 1) {
                        _id = ds_list_find_value(ds, i);
                        path_add_point(path, _id.x, _id.y, _id.sprite_height / 2);
                        unit_damage(_id, c_yellow, d);
                        d *= 0.6;
                    }
                    fx_path_bolts(path, 0);
                    ds_list_destroy(ds);
                    
                    unit_mana(id, -_chainlightning_manacost);
                    _attackcastwait = 0;
                    _target = -1;
                    _chainlightning_casting = false;
                }
            }
            else {
                _attackcastwait = 0;
                _lightningbolt_casting = false;
                _chainlightning_casting = false;
                
                if(dist < range_melee) {
                    _destx = x;
                    _desty = y;
                    if(_attackcooldown <= 0) {
                        // Regular White-Attack
                        unit_damage(_target, c_white, _attackdamage);
                        _attackcooldown = _attackspeed;
                        _target = -1;
                    }
                }
                else {
                    // Move closer 
                    dir = point_direction(x, y, _target.x, _target.y);
                    _destx = round(x + cos(degtorad(dir)) * _movespeed);
                    _desty = round(y - sin(degtorad(dir)) * _movespeed);
                    _target = -1;
                }
            }
        }
        else {
            // Move closer
            _attackcastwait = 0;
            _lightningbolt_casting = false;
            _chainlightning_casting = false;
            dir = point_direction(x, y, _target.x, _target.y);
            _destx = round(x + cos(degtorad(dir)) * _movespeed);
            _desty = round(y - sin(degtorad(dir)) * _movespeed);
            _target = -1;
        }
    }
    else if(_target._faction == _faction) {
        // Healing
        _lightningbolt_casting = false;
        _chainlightning_casting = false;
        
        if(dist < range_heal) {
            // Heal
            if(_attackcastwait <= 0) {
                // Single target heal or should we also chain this?
                // Determine which spell to cast
                t = _target;
                ds = ds_list_create();
                ds_list_add(ds, _target);
                
                // Chain to 2 additional targets
                for(i = 0;i < 2;i += 1) {
                    j = -1;
                    
                    maxhp = 0;
                    with(obj_unit) {
                        if(_faction == other._faction) {
                            jdist = unit_dist(id, t);
                            if(jdist < range_totem && ds_list_find_index(ds, id) < 0) {
                                if(_maxhealth - _health > maxhp) {
                                    j = id;
                                    maxhp = _maxhealth - _health;
                                    continue;
                                }
                            }
                        }
                    }
                    
                    if(j != -1) {
                        ds_list_add(ds, j);
                        t = j;
                    }
                    else break;
                }
                if(ds_list_size(ds) >= 2 && _manatype_mana >= _chainheal_manacost) _chainheal_casting = true;
                else if((_target._maxhealth - _target._health) >= _healingwave_amount * .75 && _manatype_mana >= _healingwave_manacost) _healingwave_casting = true;
                else if(_manatype_mana >= _lesserhealingwave_manacost) _lesserhealingwave_casting = true;
                ds_list_destroy(ds);
            }
            
            if(_healingwave_casting && _manatype_mana >= _healingwave_manacost) {
                // Shaman Special Ability: Healing Wave
                _attackcasttime = _healingwave_casttime;
                
                _attackcastwait += 1;
                if(_attackcastwait < _attackcasttime) {
                    _destx = x;
                    _desty = y;
                }
                else {
                    // Cast completed!
                    unit_heal(_target, _healingwave_amount);
                    heal_fx(_target, 2);
                    unit_mana(id, -_healingwave_manacost);
                    _attackcastwait = 0;
                    _target = -1;
                    _healingwave_casting = false;
                }
            }
            else if(_lesserhealingwave_casting && _manatype_mana >= _lesserhealingwave_manacost) {
                // Shaman Special Ability: Lesser Healing Wave
                _attackcasttime = _lesserhealingwave_casttime;
                
                _attackcastwait += 1;
                if(_attackcastwait < _attackcasttime) {
                    _destx = x;
                    _desty = y;
                }
                else {
                    // Cast completed!
                    unit_heal(_target, _lesserhealingwave_amount);
                    heal_fx(_target, 2);
                    unit_mana(id, -_lesserhealingwave_manacost);
                    _attackcastwait = 0;
                    _target = -1;
                    _lesserhealingwave_casting = false;
                }
            }
            else if(_chainheal_casting && _manatype_mana >= _chainheal_manacost) {
                // Shaman Special Ability: Chain Heal
                _attackcasttime = _chainheal_casttime;
                
                _attackcastwait += 1;
                if(_attackcastwait < _attackcasttime) {
                    _destx = x;
                    _desty = y;
                }
                else {
                    // Cast completed!
                    t = _target;
                    d = _chainheal_amount; // Effect of chain heal gets progressively weaker the number of times it chains
                    ds = ds_list_create();
                    ds_list_add(ds, _target);
                    
                    // Chain to 2 additional targets
                    for(i = 0;i < 2;i += 1) {
                        j = -1;
                        
                        maxhp = 0;
                        with(obj_unit) {
                            if(_faction == other._faction) {
                                jdist = unit_dist(id, t);
                                if(jdist < range_totem && ds_list_find_index(ds, id) < 0) {
                                    if(_maxhealth - _health > maxhp) {
                                        j = id;
                                        maxhp = _maxhealth - _health;
                                        continue;
                                    }
                                }
                            }
                        }
                        
                        if(j != -1) {
                            ds_list_add(ds, j);
                            t = j;
                        }
                        else break;
                    }
                    
                    path = path_add();
                    path_set_closed(path, false);
                    dir = point_direction(x, y, _target.x, _target.y);
                    path_add_point(path, x + cos(degtorad(dir)) * 10, y - sin(degtorad(dir)) * 10, sprite_height / 2);
                    for(i = 0;i < ds_list_size(ds); i += 1) {
                        _id = ds_list_find_value(ds, i);
                        path_add_point(path, _id.x, _id.y, _id.sprite_height / 2);
                        unit_heal(_id, d);
                        heal_fx(_id, 2);
                        d *= 0.6;
                    }
                    fx_path_bolts(path, 1);
                    ds_list_destroy(ds);
                    
                    unit_mana(id, -_chainheal_manacost);
                    _attackcastwait = 0;
                    _target = -1;
                    _chainheal_casting = false;
                }
            }
            else {
                // We must have fucked up here... Hmm.
                _healingwave_casting = false;
                _lesserhealingwave_casting = false;
                _chainheal_casting = false;
                _target = -1;
            }
        }
        else {
            // Move closer
            _attackcastwait = 0;
            _healingwave_casting = false;
            _lesserhealingwave_casting = false;
            _chainheal_casting = false;
            if(_target != id) {
                dir = point_direction(x, y, _target.x, _target.y);
                _destx = round(x + cos(degtorad(dir)) * _movespeed);
                _desty = round(y - sin(degtorad(dir)) * _movespeed);
            }
            _target = -1;
        }
    } 
    else _target = -1;
}
else {
    _attackcastwait = 0;
    _healingwave_casting = false;
    _lesserhealingwave_casting = false;
    _chainheal_casting = false;
    _lightningbolt_casting = false;
    _chainlightning_casting = false;
    _target = -1;
}

if(_taunted_duration > 0) _target = _taunted_by;

// This is after targetting has been adjusted and casts completed
if(!units_exists(_target)) {
    // Move elsewhere
    _attackcastwait = 0;
    _lightningbolt_casting = false;
    _chainlightning_casting = false;
    
    var priority, maxid;
    priority = 99;
    maxid = -1;
    maxhp = 9999;
    
    with(obj_unit) {
        if(_faction != other._faction) {
            // Look for enemy targets
            dist = unit_dist(id, other);
            if(!(!_stealthed || (_stealthed && dist <= _stealthed_visibility))) continue;
            if(dist < _attackrange) {
                // We want to store polymorphed units in the queue, but prioritize them so that everything else gets smacked before they do
                if(_polymorphed) {
                    if(priority > 9 || (priority == 9 && _health < maxhp)) {
                        priority = 9;
                        maxid = id;
                        maxhp = _health;
                        }
                    continue;
                }
                
                // First and foremost, check enemies within my range
                if(priority > 4 || (_health < maxhp && priority == 4)) {
                    priority = 4;
                    maxid = id;
                    maxhp = _health;
                    continue;
                }
            }
            else if(dist < _sightdistance) {
                // We want to store polymorphed units in the queue, but prioritize them so that everything else gets smacked before they do
                if(_polymorphed) {
                    if(priority > 10 || (priority == 10 && _health < maxhp)) {
                        priority = 10;
                        maxid = id;
                        maxhp = _health;
                        }
                    continue;
                }
                
                // Attempt to move towards the enemy
                if(priority > 6 || (_health < maxhp && priority == 6)) {
                    priority = 6;
                    maxid = id;
                    maxhp = _health;
                    continue;
                }
            }
        }
    }
    
    // A target has been found!
    if(maxid != -1) _target = maxid;
    else {
        // We need to find a target somehow...
        // Anyone moving towards something within my sight?
        with(obj_unit) {
            if(_faction == other._faction && _jobclass != class_healer) {
                dist = unit_dist(id, other);
                if(dist < _sightdistance) {
                    if((_destx != x || _desty != y) && units_exists(_target)) {
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
            _message = "*sigh*";
            _pause -= 1;
            if(_pause <= 0) {
                // Go searching for something to kill on our own... but only if our totems are gone
                if(!units_exists(_totem_water) && !units_exists(_totem_wind) && !units_exists(_totem_fire) && !units_exists(_totem_earth)) {
                    _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
                    _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
                    _pause = room_speed * (1 + random(4)); // Pause for a few seconds
                }
                else _message = "...";
            }
        }
    }
    
    // That's all fine and dandy... but does anyone need our help? Are they not going to get a heal in time?!
    if(_manatype_mana >= _lesserhealingwave_manacost) {
        maxhp = 0;
        priority = 99;
        with(obj_unit) {
            if(_faction == other._faction) {
                // I only care about my own faction and among them, whom is the most damage in my sight
                dist = unit_dist(id, other);
                if(dist < _sightdistance) {
                    calculate_incoming_effects(id, other.id);
                    hp = ((_maxhealth - _health) - global.calc_healing);
                    if(hp > other._lesserhealingwave_amount && ((priority > 5 || (priority == 5 && hp > maxhp)) || id == other.id)) {
                        maxhp = hp;
                        priority = 5 - (id == other.id); // 4 if it's me
                        other._target = id;
                        continue;
                    }
                }
            }
        }
    }
}

/*
// Shaman Special Ability: Wind Sheer

// Shaman Special Ability: Purge
*/

// Default actions
event_inherited();

depth = -y;
