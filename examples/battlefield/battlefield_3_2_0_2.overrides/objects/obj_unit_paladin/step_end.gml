if(global.toggle_pause) exit;

var dist, dir, maxid, maxdist, maxhp, hp, priority, n, me;
me = id;

// A dead Paladin takes all of its effects with it
if(dead) {
    paladin_release();
    exit;
}

// Decrement cooldowns
_judgement_cooldown -= 1;
_crusaderstrike_cooldown -= 1;
_consecration_cooldown -= 1;
_divineshield_cooldown -= 1;
_bop_cooldown -= 1;
_hoj_cooldown -= 1;
if(_divineshield_cooldown == 0) create_text_effect(x, y, c_yellow, "-divine shield ready-");

// Running effects: Divine Shield
if(_divineshield_timer > 0) {
    _divineshield_timer -= 1;
    if(_divineshield_timer <= 0) {
        _damagereduction -= 1;
        _blendcolor = c_white;
        create_text_effect(x, y, c_yellow, "-divine shield faded-");
    }
}

// Running effects: Blessing of Protection
if(_bop_timer > 0) {
    _bop_timer -= 1;
    if(_bop_timer <= 0 || !instance_exists(_bop_target)) {
        if(instance_exists(_bop_target)) {
            _bop_target._damagereduction -= 1;
            if(!_bop_target.dead) _bop_target._blendcolor = c_white;
            create_text_effect(_bop_target.x, _bop_target.y, c_yellow, "-protection faded-");
        }
        _bop_timer = 0;
        _bop_target = -1;
    }
}

// Running effects: Hammer of Justice stun
if(_hoj_timer > 0) {
    _hoj_timer -= 1;
    if(_hoj_timer <= 0 || !instance_exists(_hoj_target)) {
        if(instance_exists(_hoj_target)) { if(_hoj_target._stun_timer <= 0) _hoj_target._stunned = false; } // a Rogue's stun may still hold it
        _hoj_timer = 0;
        _hoj_target = -1;
    }
}

// Running effects: Consecration (damages every half second)
// Each damage tick sends a golden pulse across the consecrated ground, so it visibly throbs while active
if(_consecration_timer > 0) {
    _consecration_timer -= 1;
    if(_consecration_timer mod (room_speed / 2) == 0) {
        with(obj_unit) {
            if(_faction != other._faction && !dead) {
                if(point_distance(x, y, other._consecration_x, other._consecration_y) < other._consecration_range) {
                    unit_damage(id, c_yellow, other._consecration_damage);
                }
            }
        }
        if(_consecration_timer > 0) { paladin_consecration_pulse(_consecration_x, _consecration_y, _consecration_range); fx_spell(id, "consecration"); }
    }
}

// Devotion Aura (refreshed four times a second)
_aura_tick -= 1;
if(_aura_tick <= 0) {
    paladin_aura_update();
    _aura_tick = room_speed / 4;
}

if(global.cutscene_active) {
    event_inherited();
    exit;
}
if(_stunned) exit;
if(_polymorphed) {
    _heal_casting = false;
    _casting = false;
    _attackcastwait = 0;
    event_inherited();
    exit;
}

// ----------------------------------------------------------------------------------------------
// Emergencies first
// ----------------------------------------------------------------------------------------------

// Paladin Special Ability: Divine Shield
if(_divineshield_cooldown <= 0 && _divineshield_timer <= 0 && _health / _maxhealth < 0.2 && current_time > _forbearance_end) {
    _damagereduction += 1;
    _divineshield_timer = _divineshield_duration;
    _divineshield_cooldown = _divineshield_cooldown_time;
    _forbearance_end = current_time + _forbearance_time;
    _blendcolor = c_yellow;
    create_text_effect(x, y, c_yellow, "-divine shield-");
    holy_bubble_fx(id);
}

// Paladin Special Ability: Lay on Hands
// (Skips anyone who is immune right now, e.g. this Paladin inside Divine Shield: Lay on Hands costs all
// the Paladin's mana, so it heals with Holy Light inside the bubble instead and keeps the mana.)
if(!_layonhands_used && _manatype_mana >= _layonhands_minmana) {
    maxid = -1;
    maxhp = 0.15;
    with(obj_unit) {
        if(_faction == other._faction && !dead && _jobclass != class_mirrorimage && _damagereduction < 1) {
            if(point_distance(x, y, other.x, other.y) < other._heal_range) {
                hp = _health / _maxhealth;
                if(hp < maxhp) {
                    maxhp = hp;
                    maxid = id;
                }
            }
        }
    }
    if(maxid != -1) {
        create_text_effect(x, y, c_yellow, "-lay on hands-");
        unit_heal(maxid, maxid._maxhealth - maxid._health);
        unit_mana(id, -_manatype_mana);
        _layonhands_used = true;
    }
}

// Paladin Special Ability: Blessing of Protection
// Protect a Healer, Caster or Shaman that is below 35% health and has an enemy attacking it
if(_bop_cooldown <= 0 && _bop_timer <= 0 && _manatype_mana >= _bop_cost) {
    maxid = -1;
    maxhp = 0.35;
    with(obj_unit) {
        if(_faction == other._faction && !dead && id != other.id) {
            if(_jobclass == class_healer || _jobclass == class_caster || _jobclass == class_shaman) {
                hp = _health / _maxhealth;
                if(hp < maxhp && current_time > _forbearance_end && point_distance(x, y, other.x, other.y) < other._heal_range) {
                    n = id;
                    with(obj_unit) {
                        if(_target == n && _faction != other._faction && !dead) {
                            maxhp = hp;
                            maxid = n;
                            break;
                        }
                    }
                }
            }
        }
    }
    if(maxid != -1) {
        _bop_target = maxid;
        _bop_timer = _bop_duration;
        _bop_cooldown = _bop_cooldown_time;
        maxid._damagereduction += 1;
        maxid._blendcolor = c_yellow;
        maxid._forbearance_end = current_time + _forbearance_time;
        unit_mana(id, -_bop_cost);
        create_text_effect(maxid.x, maxid.y, c_yellow, "-blessing of protection-");
        holy_bubble_fx(maxid);
    }
}

// ----------------------------------------------------------------------------------------------
// Healing: Holy Light / Flash of Light
// ----------------------------------------------------------------------------------------------
if(_heal_casting) {
    // Keep casting unless the target died, got healed by someone else or wandered off
    if(!units_exists(_heal_target)) _heal_casting = false;
    else if(_heal_target.dead || _heal_target._health >= _heal_target._maxhealth || point_distance(x, y, _heal_target.x, _heal_target.y) > _heal_range * 1.25) _heal_casting = false;

    if(!_heal_casting) {
        _attackcastwait = 0;
        _casting = false;
        _message = "";
    }
    else {
        _destx = x;
        _desty = y;
        _direction = point_direction(x, y, _heal_target.x, _heal_target.y);
        _dir = deg_to_dir(_direction);
        _attackcastwait += 1;
        if(_attackcastwait >= _attackcasttime) {
            unit_heal(_heal_target, _heal_amount);
            unit_mana(id, -_heal_cost);
            _attackcastwait = 0;
            _heal_casting = false;
            _casting = false;
            _message = "";
        }
        event_inherited();
        exit;
    }
}
else if(_manatype_mana >= _flashoflight_cost) {
    // (gm-revive overrides) the only healer around heals at 85%, otherwise only below 45%
    // ...as long as there's a group to heal (at least 2 others): alone, it heals itself like a hybrid
    var others, group;
    others = 0;
    group = 0;
    with(obj_unit) {
        if(_faction == other._faction && !dead && id != other.id && _jobclass != class_mirrorimage && point_distance(x, y, other.x, other.y) < range_heal * 1.5) {
            group += 1;
            if(_jobclass == class_healer || _jobclass == class_shaman || (_jobclass == class_druid && _shapeshift_form == druid_form_normal)) others += 1;
        }
    }
    maxid = -1;
    if(others == 0 && group >= 2) maxhp = _heal_threshold_alone; else maxhp = _heal_threshold;
    with(obj_unit) {
        if(_faction == other._faction && !dead && _jobclass != class_mirrorimage) {
            if(point_distance(x, y, other.x, other.y) < other._heal_range) {
                hp = _health / _maxhealth;
                if(hp < maxhp) {
                    maxhp = hp;
                    maxid = id;
                }
            }
        }
    }
    if(maxid != -1) {
        _heal_target = maxid;
        _heal_casting = true;
        _casting = true;
        _attackcastwait = 0;
        // Flash of Light for emergencies and small top-ups (no overhealing a big Holy Light), Holy Light for big gaps
        if(maxhp < 0.25 || _manatype_mana < _holylight_cost || maxid._maxhealth - maxid._health < _holylight_amount * 0.75) {
            _attackcasttime = _flashoflight_casttime;
            _heal_amount = _flashoflight_amount;
            _heal_cost = _flashoflight_cost;
            _message = "Flash of Light!";
        }
        else {
            _attackcasttime = _holylight_casttime;
            _heal_amount = _holylight_amount;
            _heal_cost = _holylight_cost;
            _message = "Holy Light!";
        }
        event_inherited();
        exit;
    }
}

// ----------------------------------------------------------------------------------------------
// Fighting
// ----------------------------------------------------------------------------------------------
_message = "";

// Paladin Special Ability: Hammer of Justice
// Interrupt any enemy within shout range that is casting; otherwise stun a target that is hitting a squishy ally
if(_hoj_cooldown <= 0 && _hoj_timer <= 0 && _manatype_mana >= _hoj_cost) {
    maxid = -1;
    priority = 99;
    with(obj_unit) {
        if(_faction != other._faction && !dead && !_stunimmune && !_polymorphed) {
            if(point_distance(x, y, other.x, other.y) < range_shout && (!_stealthed || point_distance(x, y, other.x, other.y) <= _stealthed_visibility)) {
                if(_attackcastwait > 0 && priority > 0) {
                    priority = 0;
                    maxid = id;
                }
                else if(units_exists(_target) && priority > 1) {
                    if(_target._faction == other._faction && (_target._jobclass == class_healer || _target._jobclass == class_caster)) {
                        priority = 1;
                        maxid = id;
                    }
                }
            }
        }
    }
    if(maxid != -1) {
        with(maxid) {
            _destx = x;
            _desty = y;
            _casting = false;
            _attackcastwait = 0;
            _stunned = true;
        }
        _hoj_target = maxid;
        _hoj_timer = _hoj_duration;
        _hoj_cooldown = _hoj_cooldown_time;
        unit_mana(id, -_hoj_cost);
        create_heroicstrike_effect(maxid.x, maxid.y);
        create_text_effect(maxid.x, maxid.y, c_yellow, "-hammer of justice-");
        fx_spell(maxid, "hammer of justice");
    }
}

// Who should I be fighting?
if(_taunted_duration > 0 && units_exists(_taunted_by)) _target = _taunted_by;
if(units_exists(_target)) {
    if(_target.dead || _target._faction == _faction) _target = -1;
}
if(!units_exists(_target)) {
    priority = 99;
    maxid = -1;
    maxdist = 9999;
    with(obj_unit) {
        if(_faction != other._faction && !dead) {
            dist = point_distance(x, y, other.x, other.y);
            if(dist >= other._sightdistance) continue;
            if(_stealthed && dist > _stealthed_visibility) continue;

            // Protect our Healers and Casters: go after whoever is attacking them
            if(units_exists(_target)) {
                if(_target._faction == other._faction && (_target._jobclass == class_healer || _target._jobclass == class_caster || _target._jobclass == class_shaman)) {
                    if(priority > 0 || (priority == 0 && dist < maxdist)) {
                        priority = 0;
                        maxid = id;
                        maxdist = dist;
                    }
                    continue;
                }
            }

            // Don't break polymorphs unless there is nothing else to do
            if(_polymorphed) {
                if(priority > 5 || (priority == 5 && dist < maxdist)) {
                    priority = 5;
                    maxid = id;
                    maxdist = dist;
                }
                continue;
            }

            if(priority > 2 || (priority == 2 && dist < maxdist)) {
                priority = 2;
                maxid = id;
                maxdist = dist;
            }
        }
    }
    if(maxid != -1) _target = maxid;
}

if(units_exists(_target)) {
    dist = point_distance(x, y, _target.x, _target.y);
    if(dist >= _attackrange) {
        // Walk up to the target
        dir = point_direction(_target.x, _target.y, x, y);
        _destx = round(_target.x + cos(degtorad(dir)) * (_attackrange - 1));
        _desty = round(_target.y - sin(degtorad(dir)) * (_attackrange - 1));
    }
    else {
        _destx = x;
        _desty = y;

        // Paladin Special Ability: Consecration
        n = 0;
        with(obj_unit) {
            if(_faction != other._faction && !dead) {
                if(point_distance(x, y, other.x, other.y) < other._consecration_range) n += 1;
            }
        }
        if(n >= 2 && _consecration_cooldown <= 0 && _consecration_timer <= 0 && _manatype_mana >= _consecration_cost) {
            _consecration_x = x;
            _consecration_y = y;
            _consecration_timer = _consecration_duration;
            _consecration_cooldown = _consecration_cooldown_time;
            unit_mana(id, -_consecration_cost);
            paladin_consecration_pulse(x, y, _consecration_range);
            create_text_effect(x, y, c_yellow, "-consecration-");
        }
        else if(_judgement_cooldown <= 0 && _manatype_mana >= _judgement_cost) {
            // Paladin Special Ability: Judgement
            create_heroicstrike_effect(_target.x, _target.y);
            create_text_effect(x, y, c_yellow, "-judgement-");
            fx_spell(_target, "judgement");
            unit_damage(_target, c_yellow, _judgement_damage);
            unit_mana(id, -_judgement_cost);
            _judgement_cooldown = _judgement_cooldown_time;
        }
        else if(_crusaderstrike_cooldown <= 0 && _manatype_mana >= _crusaderstrike_cost) {
            // Paladin Special Ability: Crusader Strike
            create_heroicstrike_effect(_target.x, _target.y);
            create_text_effect(x, y, c_yellow, "-crusader strike-");
            fx_spell(_target, "crusader strike");
            unit_damage(_target, c_yellow, _attackdamage * _crusaderstrike_multiplier);
            unit_mana(id, -_crusaderstrike_cost);
            _crusaderstrike_cooldown = _crusaderstrike_cooldown_time;
        }
        else if(_attackcooldown <= 0) {
            // Melee swing (Seal of Wisdom returns a little mana)
            unit_damage(_target, c_white, _attackdamage);
            unit_mana(id, _seal_mana);
            _attackcooldown = _attackspeed;
        }
    }
}
else {
    // Nothing to fight: follow an ally that is going somewhere, otherwise wander
    with(obj_unit) {
        if(_faction == other._faction && id != other.id && _jobclass != class_healer) {
            if(point_distance(x, y, other.x, other.y) < other._sightdistance) {
                if((_destx != x || _desty != y) && units_exists(_target)) {
                    other._destx = _destx;
                    other._desty = _desty;
                    break;
                }
            }
        }
    }

    if(_destx == x && _desty == y) {
        _pause -= 1;
        if(_pause <= 0) {
            _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
            _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
            _pause = room_speed * (1 + random(4)); // Pause for a few seconds
        }
        else _message = "*sigh*";
    }
}

// Default actions (movement, facing, animation)
event_inherited();
