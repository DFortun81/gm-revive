// Count Vaelric (gm-revive overrides): the 2013 "Elmdor" fight, rebranded as a vampire lord when the
// real Marquis Elmdor became his own raid boss (obj_boss_marquis). Same mechanics; only the lines and
// spell names changed: Muramasa is Crimson Tempest, Masamune is Sanguine Lance, Teleport is Mist Step.
event_inherited();
// (gm-revive overrides) Both armies fight him together now (a common enemy, like Zio), so his health
// is set per unit on the field here, once (the game's create event gives him 6,000 a unit)
if(!variable_local_exists("_health_per_unit")) {
    _health_per_unit = 3000;
    _maxhealth = _health_per_unit * instance_number(obj_unit);
    _health = _maxhealth;
}

if(dead) exit;

// Decrement Cooldowns
_muramasa_cooldown -= 1;
_masamune_cooldown -= 1;
_bloodsuck_cooldown -= 1;
_teleport_cooldown -= 1;

if(!_casting) {
    _masamune_casting = false;
    _muramasa_casting = false;
    _bloodsuck_casting = false;
}

if(global.toggle_pause) exit;
if(global.cutscene_active || global.cutscene_ending) exit;

ds_list_clear(_enemylist);
ds_list_clear(_targetlist);
with(obj_unit) {
    if(_faction != other._faction && !dead) {
        ds_list_add(other._enemylist, id);
        if(point_distance(x, y, other.x, other.y) < range_cast) ds_list_add(other._targetlist, id);
    }
}

var enemies, targets, i, priority, pid, index, val;
enemies = ds_list_size(_enemylist);
targets = ds_list_size(_targetlist);

if(enemies == 0) {
    _casting = false;
    _attackcastwait = 0;
    global.cutscene_focus = id;
    _target = global.cutscene_focus;
    
    _direction = 270;
    _dir = deg_to_dir(_direction);
    image_single = _dir * 4 + floor(_subindex mod 4);
}
else {
    // Do stuff
    if(ds_list_find_index(_enemylist, _target) < 0) _target = id;
    if(_target == -1) _target = id;
    
    if(!_casting) {
        if(_target == id) {
            // Pick a new target (Note: To force a target switch, set the target to the index.)
            pid = id; priority = 1000;
            for(i = 0;i < enemies; i += 1) {
                index = ds_list_find_value(_enemylist, i);
                val = ((index._health + index._absorbamount) / index._maxhealth);
                if(val < priority) {
                    priority = val;
                    pid = index;
                }
            }
            
            _target = pid;
        }
        
        if(_target != id && _target != -1) {
            // Attack that target!
            
            if(point_distance(x, y, _target.x, _target.y) > range_melee) {
                // Vaelric Special Ability: Mist Step (was Teleport). He dissolves into mist and reforms
                // behind his target, using the mist strip drawn for the later version of the game.
                if(_teleport_cooldown <= 0 && _manatype_mana > _teleport_cost) {
                    with(instance_create(x, y, obj_fx_strip)) { _spr = spr_vaelric_mist; _glow = spr_vaelric_mist_glow; _f0 = 0; _f1 = 11; _len = 18; }
                    var dir; dir = degtorad(_target._direction - 180);
                    x = _target.x + cos(dir) * (range_melee * 3);
                    y = _target.y - sin(dir) * (range_melee * 3);
                    _destx = x;
                    _desty = y;
                    with(instance_create(x, y, obj_fx_strip)) { _spr = spr_vaelric_mist; _glow = spr_vaelric_mist_glow; _f0 = 11; _f1 = 0; _len = 18; _master = other.id; }
                    unit_mana(id, -_teleport_cost);
                    _teleport_cooldown = _teleport_cooldown_time;
                }
            }
            
            if(targets > 1) {
                // Vaelric Special Ability: Crimson Tempest (was Muramasa)
                if(_muramasa_cooldown <= 0 && _manatype_mana > _muramasa_cost) {
                    _attackcasttime = _muramasa_casttime;
                    _attackcastwait = _muramasa_casttime;
                    _muramasa_casting = true;
                    _casting = true;
                    create_text_effect(x, y, c_white, "-crimson tempest-");
                    with(instance_create(x, y, obj_muramasa)) { _range = range_cast; _master = other.id; }
                    exit;
                }
            }
            
            // Vaelric Special Ability: Sanguine Lance (was Masamune)
            // This is damage is done instantly to a group, split evenly among them. If there are fewer people in range, the damage does significantly more to them.
            if(_masamune_cooldown <= 0 && _manatype_mana > _masamune_cost) {
                _attackcasttime = _masamune_casttime;
                create_text_effect(x, y, c_white, "-sanguine lance-");
                _masamune_casting = true;
                _casting = true;
                exit;
            }
            
            // Elmdor Special Ability: Blood Suck
            // Damage over 6 seconds, channelled. Heals for 400% of the damage done
            if(_bloodsuck_cooldown <= 0 && _manatype_mana > _bloodsuck_cost) {
                _attackcastwait = _bloodsuck_casttime;
                _attackcasttime = _bloodsuck_casttime;
                create_text_effect(x, y, c_white, "-blood suck-");
                _bloodsuck_casting = true;
                _casting = true;
                exit;
            }
        }
    }
    
    if(_casting) {
        _destx = x;
        _desty = y;
        
        // Perform the cast
        if(_muramasa_casting) {
            // Perform the Muramasa Spell Animations and do damage
            _attackcastwait -= 1;
            _attackcasttime = _muramasa_casttime;
            _message = "Drown in a tempest of blood!";
            
            if(_attackcastwait mod (room_speed / 2) == 0) {
                for(i = 0;i < targets; i += 1) {
                    index = ds_list_find_value(_targetlist, i);
                    unit_damage(index, c_yellow, _muramasa_amount / (_muramasa_casttime / (room_speed / 2)));
                }
            }
            
            if(_attackcastwait <= 0) {
                // Stop casting
                _attackcastwait = -1;
                unit_mana(id, -_muramasa_cost);
                create_text_effect(x, y, c_white, "-crimson tempest ends-");
                _muramasa_cooldown = _muramasa_cooldown_time;
                _casting = false;
                _target = id;
                exit;
            }
        }
        if(_masamune_casting) {
            // Perform the Masamune Spell Animations and do damage
            _attackcastwait += 1;
            _attackcasttime = _masamune_casttime;
            _message = "Your lives are mine to spend!";
            
            if(_attackcastwait >= _attackcasttime) {
                // Stop casting
                for(i = 0;i < targets; i += 1) {
                    index = ds_list_find_value(_targetlist, i);
                    unit_damage(index, c_yellow, max(80, _masamune_amount / targets));
                }
                _attackcastwait = -1;
                create_text_effect(x, y, c_white, "-sanguine lance ends-");
                unit_mana(id, -_masamune_cost);
                _masamune_cooldown = _masamune_cooldown_time;
                _casting = false;
                _target = id;
                exit;
            }
        }
        
        if(_bloodsuck_casting) {
            // Perform the Blood Suck Spell Animations and do damage
            _attackcastwait -= 1;
            _attackcasttime = _bloodsuck_casttime;
            if(_attackcastwait > (_attackcasttime / 2)) _message = "Here dying, join my legion of undeath...";
            else _message = "Your blood, the roses on unhallow'd graves!";
            
            if(_target != id) {
                create_bloodsuck_effect(_target.x, _target.y, id);
                unit_damage(_target, c_yellow, _bloodsuck_amount / _bloodsuck_casttime, true);
                if(_attackcastwait mod (room_speed / 2) == 0) unit_heal(id, (_bloodsuck_amount / (_bloodsuck_casttime / (room_speed / 2))) * 4);
                if(!_target._stunimmune) {
                    _target._destx = _target.x;
                    _target._desty = _target.y;
                    _target._target = -1;
                    _target._casting = false;
                    _target._stunned = true;
                }
            }
            
            if(_attackcastwait < 0 || _target == id) {
                // Stop casting
                _attackcastwait = -1;
                if(_target != id) _target._stunned = false;
                unit_mana(id, -_bloodsuck_cost);
                create_text_effect(x, y, c_white, "-blood suck ends-");
                _bloodsuck_cooldown = _bloodsuck_cooldown_time;
                _casting = false;
                _target = id;
                exit;
            }
        }
    }
}