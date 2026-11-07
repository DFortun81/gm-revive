// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
if(global.toggle_pause) exit;

var dist, dir, maxid, maxdist, maxhp, hp, priority;
priority = 99;
maxhp = 99;
maxid = -1;
maxdist = 9999;

if(dead || _stunned) exit;

// Decrement cooldowns
_charge_cooldown -= 1;
_execute_cooldown -= 1;
_bloodrage_cooldown -= 1;
_heroicstrike_cooldown -= 1;
_intimidate_cooldown -= 1;
_taunt_cooldown -= 1;
_laststand_cooldown -= 1;
_thunderclap_cooldown -= 1;
if(_laststand_cooldown == 0) create_text_effect(x, y, c_yellow, "-last stand ready-");

if(global.cutscene_active) exit;

// Warrior Special Ability: Bloodrage
// The effect of Bloodrage will persist through Polymorph as well as BREAK ALL Polymorph effects! (even while polymorphed)
if(_bloodrage_cooldown <= 0 && (units_exists(_target) || _polymorphed)) {
    if((_health / _maxhealth) > 0.25 || _bloodrage_progress > 0) {
        // We don't want to spam the player with text information, have this data print out over time (once per second)
        if((_bloodrage_progress mod room_speed) == 0 && _health > _maxhealth * 0.10) {
            _health = max(1, _health - (_maxhealth * 0.10) / (_bloodrage_duration / room_speed));
            create_text_effect(x, y, c_red, string((_maxhealth * 0.10) / (_bloodrage_duration / room_speed)));
            unit_mana(id, (_manatype_maxrage * 0.5) / (_bloodrage_duration / room_speed));
        }
        
        // The first tick of Bloodrage will notify the player of its presence
        if(_bloodrage_progress == 0) create_text_effect(x, y, c_yellow, "-bloodrage-");
        
        // Countdown until the effect wears off
        _bloodrage_progress += 1;
        if(_bloodrage_progress > _bloodrage_duration) {
            _bloodrage_progress = 0;
            _bloodrage_cooldown = _bloodrage_cooldown_time;
        }
    }
}

// Warrior Special Ability: Last Stand
// This ability reduces the amount of damage the Warrior takes by 30%. In addition, increases total health by 100% for 12 seconds.
// After this period, health and damage reduction effects are reverted. Cooldown is 5 minutes.
if(_laststand_cooldown <= 0) {
    if(!_laststand_used) {
        if(_health / _maxhealth < 0.20 && _health > 0) {
            // Make our Last Stand!
            _laststand_health = _maxhealth;
            _health += _laststand_health;
            _maxhealth += _laststand_health;
            _damagereduction += 0.3;
            _attackcasttime = _laststand_duration;
            create_text_effect(x, y, c_yellow, "-last stand-");
            _laststand_used = true;
        }
    }
    else {
        _laststand_progress += 1;
        _attackcastwait = _laststand_progress; // Show this information to the player via the castbar
        if(_laststand_progress >= _laststand_duration) {
            _maxhealth -= _laststand_health;
            _health -= _laststand_health;
            _damagereduction -= 0.3;
            _attackcasttime = 0;
            _attackcastwait = 0;
            create_text_effect(x, y, c_yellow, "-last stand faded-");
            _laststand_cooldown = _laststand_cooldown_time;
            _laststand_progress = 0;
            _laststand_used = false;
        }
    }
}

// Warriors don't enjoy being polymorphed too much. It fills them with rage!
// A Warrior will game 0.05% rage for every tick (60 ticks per second) that they are polymorphed
if(_polymorphed) unit_mana(id, 0.05);
else {
    // If a Warrior doesn't know who he wants to kill, he will instead start to lose rage
    if(_target == -1) unit_mana(id, -0.05);
    else unit_mana(id, 0.05);
}

// unit_lists_populate();

// Check if Charge is off Cooldown (assuming the Warrior is not polymorphed)
if(_charge_cooldown <= 0 && !_charge_casting && !_charge_charging && !_polymorphed && _taunted_duration <= 0) {
    // Find a target
    with(obj_unit) {
        if(_faction != other._faction) {
            dist = unit_dist(id, other);
            
            // I can only charge at things within my sight range (_sightdistance) and outside of my attack range
            if(dist < _sightdistance && dist > _attackrange && (!_stealthed || (_stealthed && dist <= _stealthed_visibility))) {
                hp = _health / _maxhealth;
                if(_polymorphed) {
                    if(priority > 9 || (priority == 9 && hp < maxhp)) {
                        priority = 9;
                        maxid = id;
                        maxhp = hp;
                        }
                    continue;
                }
                
                if(_jobclass == 0) {
                    // If a warrior is smacking on a healer or caster, help them!
                    if(units_exists(_target)) {
                        if(_target._jobclass == class_healer) {
                            // Healer
                            priority = -3;
                            maxid = id;
                            maxhp = hp;
                            continue;
                        }
                        else if(_target._jobclass == class_caster && priority > -2) {
                            // Caster
                            priority = -2;
                            maxid = id;
                            maxhp = hp;
                            continue;
                        }
                    }
                    if(priority > 6 || (priority == 6 && hp < maxhp)) {
                        priority = 6;
                        maxid = id;
                        maxhp = hp;
                        continue;
                    }
                }
                else if(_attackcastwait > 0) {
                    // Is the target casting a spell?
                    if(_jobclass == class_caster) {
                        // If the target is a Mage and he's casting polymorph or evocation (Absolutely a MUST to interrupt!)
                        if((_polymorph_casting || _evocation_casting || _blizzard_casting) && (priority > -1 || (priority == -1 && hp < maxhp))) {
                            priority = -1;
                            maxid = id;
                            maxhp = hp;
                            continue;
                        }
                    }
                    else if(_jobclass == class_healer && (priority > 0 || (priority == 0 && hp < maxhp))) {
                        // If the target is a Healer and he's casting
                        priority = 0;
                        maxid = id;
                        maxhp = hp;
                        continue;
                    }
                }
                else if(_jobclass == class_healer && (priority > 1 || (priority == 1 && hp < maxhp))) {
                    // If it's a Healer and there's not already a Healer as the priority (unless the health of this Healer is less than the other!)
                    priority = 1;
                    maxid = id;
                    maxhp = hp;
                    continue;
                }
                else if(_jobclass == class_caster && (priority > 2 || (priority == 2 && hp < maxhp))) {
                    // If it's a Caster and there's not already a Caster (or greater) as the priority (unless the health of this Caster is less than the other!)
                    priority = 2;
                    maxid = id;
                    maxhp = hp;
                    continue;
                }
                
                if(priority > 6 || (priority == 6 && hp < maxhp)) {
                    // If it's nothing more significant... just justify it as a possible target taking health into consideration.
                    priority = 6;
                    maxid = id;
                    maxhp = hp;
                    continue;
                }
            }
        }
    }
    if(maxid != -1) _target = maxid;
    
    if(units_exists(_target)) _charge_casting = true;
}

// If the Warrior is taking way too much damage, he will first look around for one and then attempt to move into its casting range
if(_health / _maxhealth <= 0.75) {
    // Am I below 75% health? ^
    _nearesthealer = -1;
    maxdist = 9999;
    
    // Then I'd best find someone who can heal me and get to them quickly!
    with(obj_unit) {
        if(_faction == other._faction && _canheal) {
            // Only find healers of my faction
            dist = unit_dist(id, other);
            if(dist < _attackrange) {
                // I'm already in the caster's range! Hopefully he'll notice my health soon enough!
                _nearesthealer = -1;
                maxdist = dist;
                break;
            }
            else if(dist < _sightdistance) {
                // I'm within his field of vision, I'd best start moving in his general direction
                if(dist < maxdist) {
                    // Is this new healer closer than the last?
                    maxdist = dist;
                    _nearesthealer = id;
                    continue;
                }
            }
        }
    }
    
    // If a healer (that was out of range) was found...
    if(_nearesthealer != -1) {
        // Charging into battle without a sufficient amount of health is probably a bad idea.
        // Let's not do that!
        _charge_casting = false;
        
        // Move towards that healer!
        dir = point_direction(_nearesthealer.x, _nearesthealer.y, x, y);
        _destx = round(_nearesthealer.x + cos(degtorad(dir)) * (_nearesthealer._attackrange - 1));
        _desty = round(_nearesthealer.y - sin(degtorad(dir)) * (_nearesthealer._attackrange - 1));
        _dir = deg_to_dir(point_direction(x, y, _nearesthealer.x, _nearesthealer.y));
    }
}

if(_charge_casting) {
    if(units_exists(_target)) {
        _message = "Get over here!";
        
        dist = unit_dist(id, _target);
        dir = point_direction(_target.x, _target.y, x, y);
        if(dist < _sightdistance && dist > _attackrange * 1.1 && (!_stealthed || (_stealthed && dist <= _stealthed_visibility))) {
            // My target is within my sight, let's get him!
            _destx = round(_target.x + cos(degtorad(dir)) * (_attackrange - 1 + unit_hitbox(_target) + unit_hitbox(id)));
            _desty = round(_target.y - sin(degtorad(dir)) * (_attackrange - 1 + unit_hitbox(_target) + unit_hitbox(id)));
            
            _dir = deg_to_dir(point_direction(x, y, _target.x, _target.y));
            
            create_charge_effect(x, y);
            charge_fx(_target);
            
            _movespeed = _normal_movespeed * 3;
            _charge_charging = true;
        }
        else {
            // Was I casting charge when I decided to stop?
            if(_charge_charging) {
                _charge_charging = false;
                _charge_cooldown = _charge_cooldown_timer;
                _movespeed = _normal_movespeed;
                unit_mana(id, 20);
            }
            _message = "";
            _charge_casting = false;
        }
    }
    else {
        // Was I casting charge when I decided to stop?
        if(_charge_charging) {
            _charge_charging = false;
            _charge_cooldown = _charge_cooldown_timer;
            _movespeed = _normal_movespeed;
            unit_mana(id, 20);
        }
        _message = "";
        _charge_charging = false;
        _charge_casting = false;
    }
}

// If we're not casting charge, then do normal functionality
if(!_charge_casting && !_polymorphed) {
    _message = "";
    if(units_exists(_target)) {
        dist = unit_dist(id, _target);
        if(_target._stealthed && dist > _target._stealthed_visibility) { _target = -1; exit; }
        if(dist < range_shout && !_target._tauntimmune) {
            // Within Shout range
            if(_manatype_rage >= 5 && _taunt_cooldown <= 0 && _target._target != id) {
                // Warrior Special Ability: Taunt
                // This ability redirects the targetting effects of a single target to the Warrior.
                // This ability ignores all pre-existing taunt effects on the target when doing so.
                // This ability can be used once every 6 seconds. Effect last for 6 seconds. (before DR)
                var t;
                t = false;
                if(units_exists(_target._target)) {
                    if(_target._target._faction == _faction) {
                        if((_target._target._jobclass >= class_healer || _target._target._health < _health)) {
                            create_text_effect(_target.x, _target.y, c_yellow, "-taunted-");
                            _target._taunted_by = id;
                            _target._taunted_duration = room_speed * 6;
                            _target._target = id;
                            t = true;
                        }
                    }
                }
                
                if(!t) {
                    // Taunt something in range that's smacking something they're not supposed to be smacking
                    var total, need; // Need will represent the number of targets smacking
                    total = 0; need = 0;
                    
                    with(obj_unit) {
                        if(_faction != other._faction) {
                            dist = unit_dist(id, other);
                            if(dist < range_shout && !_stealthed && !_tauntimmune) {
                                total += 1; // Add to the total count
                                
                                if(_target != other.id && units_exists(_target)) {
                                    if(_target._jobclass >= class_healer && _target._faction == other._faction) {
                                        need += 1;
                                        create_text_effect(x, y, c_yellow, "-taunted-");
                                        _taunted_by = other.id;
                                        _taunted_duration = room_speed * 6;
                                        _target = other.id;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
                
                if(t) {
                    // We used Taunt!
                    unit_mana(id, -5);
                    _taunt_cooldown = _taunt_cooldown_time;
                }
            }
            else if(_manatype_rage >= 10 && _intimidate_cooldown <= 0) {
                // Warrior Special Ability: Intimidating Shout
                // This ability is an AoE (Area of Effect) Taunt spell that redirects the targetting effects of all enemies 
                // Within Shout distance (_attackrange * 2). Does NOT effect targets already affected by a Taunt effect.
                // This ability can be used once every 30 seconds. Effect last for 6 seconds. (before DR)
                var total, need; // Need will represent the number of targets smacking
                total = 0; need = 0;
                
                with(obj_unit) {
                    if(_faction != other._faction) {
                        dist = unit_dist(id, other);
                        if(dist < range_shout && !_stealthed && !_tauntimmune) {
                            total += 1; // Add to the total count
                            
                            if(_target != other.id && units_exists(_target)) {
                                if((_target._jobclass > class_warrior || (_target._jobclass == class_warrior && _health < other._health)) && _target._faction == other._faction) need += 1;
                            }
                        }
                    }
                }
                if(need >= 1 && total >= 2) {
                    // Yes, we decided to use Intimidating Shout
                    unit_mana(id, -10);
                    create_text_effect(x, y, c_yellow, "-intimidating shout-");
                    with(obj_unit) {
                        if(_faction != other._faction) {
                            dist = unit_dist(id, other);
                            if(dist < range_shout && !_stealthed && !_tauntimmune) {
                                if(_jobclass != class_healer && (unit_unfriendly(_target, _faction) || !units_exists(_target))) {
                                    _taunted_by = other.id;
                                    _taunted_duration = room_speed * 6;
                                    _target = other.id;
                                }
                            }
                        }
                    }
                    _intimidate_cooldown = _intimidate_cooldown_time;
                }
            }
        }
        
        
        
        // The Warrior is a Melee-Range sort of killer. They need to be up close and personal to destroy their enemies!
        dist = unit_dist(id, _target);
        if(dist < _attackrange) {
            if((_target._health / _target._maxhealth) <= 0.35 && _manatype_rage >= 20 && _execute_cooldown <= 0) {
                // Execute!
                create_text_effect(x, y, c_yellow, "-execute!-");
                class_strike_fx(_target, 1);
                unit_damage(_target, c_yellow, _manatype_rage + _attackdamage * 4);
                unit_mana(id, -_manatype_rage);
                _execute_cooldown = _execute_cooldown_time;
            }
            else if(_manatype_rage >= _thunderclap_cost && _thunderclap_cooldown <= 0) {
                // Warrior Special Ability: Thunderclap
                // Blasts nearby enemies increasing the time between their attacks by 20% for 30 seconds and doing 16-20 damage to them.
                shockwave_fx(range_melee * 2);
                create_text_effect(x, y, c_white, "-thunderclap-");
                with(obj_unit) {
                    if(_faction != other._faction) {
                        dist = unit_dist(id, other);
                        
                        // I can only charge at things within my sight range (_sightdistance) and outside of my attack range
                        if(dist < range_melee * 2) {
                            unit_damage(id, c_yellow, other._thunderclap_damage + round(random(4)));
                        }
                    }
                }
                unit_mana(id, -_thunderclap_cost);
                _thunderclap_cooldown = _thunderclap_cooldown_time;
            }
            else if(_manatype_rage >= 10 && _heroicstrike_cooldown <= 0) {
                // Heroic Strike!
                class_strike_fx(_target, 0);
                unit_damage(_target, c_yellow, _attackdamage * 2.25);
                unit_mana(id, -10);
                _heroicstrike_cooldown = _heroicstrike_cooldown_time;
            }
            else if(_attackcooldown <= 0) {
                // Regular White-Attack
                unit_damage(_target, c_white, _attackdamage);
                unit_mana(id, 2);
                _attackcooldown = _attackspeed;
            }
        }
        else {
            // Get closer!
            dir = point_direction(x, y, _target.x, _target.y);
            _destx = round(x + cos(degtorad(dir)) * _movespeed);
            _desty = round(y - sin(degtorad(dir)) * _movespeed);
            _target = -1;
        }
    }
    
    if(_taunted_duration > 0) _target = _taunted_by;
    
    if(!units_exists(_target)) {
        // Let's find a suitable victim... preferably one that can be executed if I can cast it!
        priority = 99;
        maxid = -1;
        maxhp = 9999;
        
        with(obj_unit) {
            if(_faction != other._faction) {
                // Look for enemy targets
                dist = unit_dist(id, other);
                if(!(!_stealthed || (_stealthed && dist < _stealthed_visibility))) continue;
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
}
event_inherited();