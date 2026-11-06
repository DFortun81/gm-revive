 if(global.toggle_pause) exit;

// Decrement Cooldowns
_polymorph_cooldown -= 1;
_evocation_cooldown -= 1;
_blink_cooldown -= 1;
_mirrorimage_cooldown -= 1;
_blizzard_cooldown -= 1;
_fireblast_cooldown -= 1;
_manashield_cooldown -= 1;

if(dead) exit;
if(_stunned) {
    // A stun breaks Polymorph and Blizzard casts (added by gm-revive overrides)
    if(_polymorph_casting || _blizzard_casting) {
        if(_blizzard_casting) _blizzard_cooldown = _blizzard_cooldown_time;
        _casting = false;
        _polymorph_casting = false;
        _blizzard_casting = false;
        _attackcastwait = 0;
        _attackcasttime = _normal_attackcasttime;
    }
    exit;
}
if(_polymorphed) {
    // Reset all Unique spell cooldowns
    _casting = false;
    _attackcastwait = 0;
    _attackcasttime = _normal_attackcasttime;
    if(_evocation_casting) _evocation_cooldown = _evocation_cooldown_time;
    if(_blizzard_casting) _blizzard_cooldown = _blizzard_cooldown_time;
    _polymorph_casting = false;
    _blizzard_casting = false;
    event_inherited();
    exit;
}

var i, dir, dist, size, index, pm, bz, rng;
if(!_casting && !global.cutscene_active) {
    // Find something to cast
    _evocation_casting = false;
    _polymorph_casting = false;
    _blizzard_casting = false;
    _attackcastwait = 0;
    _target = -1;
    
    // Caster Special Ability: Evocation
    if(_evocation_cooldown <= 0 && (_manatype_mana / _manatype_maxmana) <= 0.2) {
        _casting = true;
        _evocation_casting = true;
        _attackcasttime = _evocation_castduration;
        exit;
    }
    
    // A Taunt can no longer change the target while casting
    if(_taunted_duration > 0) _target = _taunted_by;
    
    if(_target == -1) {
        // Generate a potential list of enemies
        unit_lists_populate();
        
        size = ds_list_size(_enemylist);
        if(size > 0) {
            var besthp, priority, bestdist, smacking;
            besthp = 99999999999;
            bestdist = 999999999;
            priority = 999999999;
            for(i = 0;i < size; i += 1;) {
                index = ds_list_find_value(_enemylist, i);
                dist = point_distance(x, y, index.x, index.y);
                if(dist < range_cast) {
                    // They are in casting range
                    if(index._polymorphed) {
                        if(priority > 9 || (priority == 9 && index._health < besthp)) {
                            // We don't necessarily want to start out attacking a polymorphed target, so just add it if there are no other targets.
                            priority = 9;
                            bestdist = dist;
                            besthp = index._health;
                            _target = index;
                        }
                    }
                    else {
                        // Not polymorphed, but how important is it to kill this target?
                        // Is another mage casting polymorphed on this target? (even one not in my faction)
                        smacking = false;
                        with(obj_unit_caster) {
                            if(_faction != index._faction) {
                                if(_target == index && _polymorph_casting && id != other.id) {
                                    smacking = true;
                                }
                            }
                        }
                        if((priority > 5 || (priority == 5 && index._health < besthp)) && !smacking) {
                            // We don't really care what it is we're killing, just who we're CCing. People with less health die faster!
                            priority = 5;
                            bestdist = dist;
                            besthp = index._health;
                            _target = index;
                        }
                    }
                }
                else if(dist < _sightdistance) {
                    // They are in my line of sight
                    if(index._polymorphed) {
                        if(priority > 11 || (priority == 11 && index._health < besthp)) {
                            // We don't necessarily want to start out attacking a polymorphed target, so just add it if there are no other targets.
                            priority = 11;
                            bestdist = dist;
                            besthp = index._health;
                            _target = index;
                        }
                    }
                    else {
                        // Not polymorphed, but how important is it to kill this target?
                        // Is another mage casting polymorphed on this target? (even one not in my faction)
                        smacking = false;
                        with(obj_unit_caster) {
                            if(_faction != index._faction) {
                                if(_target == index && _polymorph_casting && id != other.id) {
                                    smacking = true;
                                }
                            }
                        }
                        if((priority > 7 || (priority == 7 && index._health < besthp)) && !smacking) {
                            // We don't really care what it is we're killing, just who we're CCing. People with less health die faster!
                            // As long as we don't break CC, that is. That's a BIG NO NO!
                            priority = 7;
                            bestdist = dist;
                            besthp = index._health;
                            _target = index;
                        }
                    }
                }
            }
        }
    }
    
    if(_target == -1) {
        // There was nothing within our sights
        // Have we still failed to find a suitable kill target?
        // Hmm... why not go searching for one?
        // Anyone moving towards something within my sight?
        var i, size, index; size = ds_list_size(_allylist);
        for(i = 0;i < size;i += 1) {
            index = ds_list_find_value(_allylist, i);
            if(index._jobclass != class_healer) {
                dist = point_distance(x, y, index.x, index.y);
                if(dist < _sightdistance) {
                    if((index._destx != index.x || index._desty != index.y) && units_exists(index._target)) {
                        _destx = index._destx;
                        _desty = index._desty;
                        break;
                    }
                }
            }
        }
        
        // Still nothing? Just go somewhere that's not here!
        if(_destx == x && _desty == y) {
            _pause -= 1;
            if(_pause <= 0) {
                // Go searching for something to kill on our own
                _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
                _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
                _pause = room_speed * (1 + random(4)); // Pause for a few seconds
            }
        }
    }
    
    if(units_exists(_target)) {
        dist = point_distance(x, y, _target.x, _target.y);
        if(dist < range_cast) {
            // Instant Cast abilities
            if(_fireblast_cooldown <= 0) {
                if(_manatype_mana >= _fireblast_manacost) {
                    // Caster Special Ability: Fire Blast
                    create_text_effect(x, y, c_white, "-fire blast-");
                    unit_damage(_target, c_yellow, _fireblast_amount + round(random(_fireblast_amount) / 6));
                    unit_mana(id, -_fireblast_manacost);
                    _fireblast_cooldown = _fireblast_cooldown_time;
                }
            }
            
            
            if(_mirrorimage_cooldown <= 0 && _manatype_mana >= _mirrorimage_manacost) {
                // Caster Special Ability: Mirror Images
                create_text_effect(x, y, c_yellow, "-mirror images-");
                for(i = 0;i < 3;i += 1) {
                    with(create_mirror_image(x + cos(degtorad(i * 120)) * 16, y - sin(degtorad(i * 120)) * 16)) _angle = i * 120;
                }
                unit_mana(id, -_mirrorimage_manacost);
                _mirrorimage_cooldown = _mirrorimage_cooldown_time;
            }
            
            // Polymorph or Blizzard if the situation calls for it, otherwise Fireball (added by gm-revive overrides)
            pm = caster_polymorph_pick();
            bz = -1;
            if(pm == -1) bz = caster_blizzard_pick();
            if(pm != -1) {
                // Caster Special Ability: Polymorph
                _target = pm;
                _polymorph_casting = true;
                _attackcastwait = 0;
                _attackcasttime = _polymorph_casttime;
                _casting = true;
            }
            else if(bz != -1) {
                // Caster Special Ability: Blizzard
                _target = bz;
                _blizzard_casting = true;
                _blizzard_tick = 0;
                _attackcastwait = 0;
                _attackcasttime = _blizzard_casttime;
                _casting = true;
                create_blizzard_effect(bz.x, bz.y);
                create_text_effect(x, y, c_aqua, "-blizzard-");
            }
            else if(_manatype_mana >= _fireball_manacost) {
                // Default Attack: Fireball
                _attackcasttime = _fireball_casttime;
                _casting = true;
            }
            else _message = "WTB INNERVATE!";
        }
        else {
            // Move closer
            dir = point_direction(x, y, _target.x, _target.y);
            _destx = round(x + cos(degtorad(dir)) * _movespeed);
            _desty = round(y - sin(degtorad(dir)) * _movespeed);
        }
    }
}

if(_target != -1) {
    // This means that there is at least one target available somewhere.
    // Now check to make sure we're not being targetted. (if so, do stuff)
    var t, tar, d, mc;
    t = false; tar = -1; d = false;
    size = ds_list_size(_enemylist);
    for(i = 0;i < size; i += 1;) {
        index = ds_list_find_value(_enemylist, i);
        if(index._target == id) {
            t = true; tar = index;
            
            dist = point_distance(x, y, index.x, index.y);
            if(index._casting || dist <= range_melee) {
                d = true; // DANGER! DANGER! OH SHIT SON!
            }
        }
    }
    
    //if(_health < _maxhealth) d = true;
    
    mc = (_manashield_amount * _manashield_manacost);
    if(d && _manashield_cooldown <= 0 && _manatype_mana > mc && _absorbamount <= 0) {
        // Caster Special Ability: Mana Shield
        // The mage uses his own Mana reserves to put up a temporary absorb shield on himself.
        _manashield_cooldown = _manashield_cooldown_time;
        _absorbmax = max(_absorbmax, _manashield_amount);
        _absorbamount = min(_absorbmax, _absorbamount + _manashield_amount);
        unit_mana(id, -mc);
        //_manashield_amount = 100;
        //_manashield_manacost = 0.25; // Per point of health
    }
}

// Caster Special Ability: Blink (added by gm-revive overrides)
caster_blink_check();

// If you found something to cast... do it?
if(_casting) {
    _attackcastwait += 1;
    _destx = x;
    _desty = y;
    
    // You're casting something, but what?
    if(_evocation_casting) {
        // Evocate!
        _attackcasttime = _evocation_castduration;
        _target = -1;
        image_single = 0;
        
        if(_attackcastwait < _attackcasttime && _manatype_mana < _manatype_maxmana) {
            _message = "Evocation!";
            unit_mana(id, (_manatype_maxmana * 0.6) / _attackcasttime);
            repeat(10) create_evocation_effect(x, y, make_color_rgb(0, random(100) + 155, random(100) + 155));
        }
        else {
            _attackcastwait = 0;
            _evocation_cooldown = _evocation_cooldown_time;
            _attackcasttime = _normal_attackcasttime;
            _casting = false;
        }
    }
    else if(_blizzard_casting) {
        // Channelling Blizzard: tied to the storm's position, not the target
        caster_blizzard_channel();
    }
    else {
        // Target-Based Spells (that require range)
        if(units_exists(_target)) {
            dist = point_distance(x, y, _target.x, _target.y);
        }
        else dist = 999999;
        rng = range_cast;
        if(_polymorph_casting) rng = _polymorph_range;
        
        if(dist < rng && !global.cutscene_active) {
            // Continue casting
            if(_polymorph_casting) {
                // Casting Polymorph...
                if(_target._polymorphed) {
                    // Someone beat us to it
                    _polymorph_casting = false;
                    _casting = false;
                    _attackcastwait = 0;
                    _attackcasttime = _normal_attackcasttime;
                    _target = -1;
                }
                else if(_attackcastwait >= _attackcasttime) caster_polymorph_land();
            }
            else if(_attackcastwait >= _attackcasttime) {
                // Cast Successful (Fireball)
                with(instance_create(x, y, obj_fireball)) {
                    _master = other._target;
                    _x = other._target.x;
                    _y = other._target.y;
                    _attackdamage = other._attackdamage;
                    _source = other.id; // (gm-revive overrides) so the damage meter can credit the Caster
                }
                unit_mana(id, -_fireball_manacost);
                _attackcastwait = 0;
                _casting = false;
                _target = -1;
            }
        }
        else {
            // Stop Casting - Either out of range or polymorphed.
            _casting = false;
            _attackcastwait = 0;
            if(_evocation_casting) _evocation_cooldown = _evocation_cooldown_time;
            if(_blizzard_casting) _blizzard_cooldown = _blizzard_cooldown_time;
            _attackcasttime = _normal_attackcasttime;
            event_inherited();
            exit;
        }
    }
}

event_inherited();
depth = -y;
