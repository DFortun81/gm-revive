// Count Vaelric (gm-revive overrides): the 2013 "Elmdor" fight, rebranded as a vampire lord when the
// real Marquis Elmdor became his own raid boss (obj_boss_marquis). Same mechanics; only the lines and
// spell names changed: Muramasa is Crimson Tempest, Masamune is Sanguine Lance, Teleport is Mist Step.
event_inherited();
// (gm-revive overrides) Both armies fight him together now (a common enemy, like Zio), so his health
// is set per unit on the field here, once (the game's create event gives him 6,000 a unit)
if(!variable_local_exists("_health_per_unit")) {
    _health_per_unit = 2600;
    _maxhealth = _health_per_unit * instance_number(obj_unit);
    _health = _maxhealth;
    _drain_break_frac = 0.035;   // Blood Suck breaks after this share of his health in damage
    _drain_guard = 0.2;          // Kick and Wind Shear only work once this much of a drain is left
    _thrall_max = 4;
    _bloodsuck_amount = 600;     // (was 360) over the 4 s drain; it quickens, so most of it comes at the end             // thralls at once
    _drain_victim = -1;   // Blood Suck: who he's draining, and how they looked before
    _drain_y0 = 0;
    _drain_blend0 = c_white;
    _drain_pulse = 0;     // flares his red glow when a drain heals him
    _drain_taken = 0;     // damage he's taken during this drain (enough of it breaks the drain)
    _phase_time = 0;      // Mist Step: steps left out of phase (gone as mist, between leaving and reforming)
}
if(_drain_pulse > 0) _drain_pulse -= 1;

if(dead) exit;

// Decrement Cooldowns
_muramasa_cooldown -= 1;
_masamune_cooldown -= 1;
_bloodsuck_cooldown -= 1;
_teleport_cooldown -= 1;

// (gm-revive overrides) A Kick or Wind Shear stops Blood Suck (unit_interrupt clears _casting)
if(!_casting && _bloodsuck_casting) vaelric_drain_break("interrupted");
if(!_casting && _drain_victim != -1) vaelric_drain_end();
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
        if(unit_dist(id, other) < range_cast) ds_list_add(other._targetlist, id);
    }
}

var enemies, targets, i, priority, pid, index, val, p;
enemies = ds_list_size(_enemylist);
targets = ds_list_size(_targetlist);

// (gm-revive overrides) Out of phase after Mist Step: he waits as mist, then reforms near a target
if(_phase_time > 0) {
    _phase_time -= 1;
    image_alpha = 0; _stealthed_alpha = 0;
    _destx = x; _desty = y;
    if(_phase_time <= 0) vaelric_mist_reform();
    exit;
}

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
            
            if(unit_dist(id, _target) > range_melee) {
                // Vaelric Special Ability: Mist Step (was Teleport). He dissolves into mist and reforms
                // behind his target, using the mist strip drawn for the later version of the game.
                if(_teleport_cooldown <= 0 && _manatype_mana > _teleport_cost) {
                    with(instance_create(x, y, obj_fx_strip)) { _spr = spr_vaelric_mist; _glow = spr_vaelric_mist_glow; _f0 = 0; _f1 = 11; _len = 18; }
                    repeat(4) with(instance_create(x, y, obj_fx_bat)) _ang = random(360);
                    // (gm-revive overrides) He stays out of phase for a second and a half before he
                    // reforms (vaelric_mist_reform), so the armies get a chance to move about; while he's
                    // gone he can't be seen, targeted or hurt
                    _phase_time = round(room_speed * 1.5);
                    _stealthed = true; _stealthed_visibility = 0;
                    image_alpha = 0; _stealthed_alpha = 0;
                    _destx = x; _desty = y;
                    with(obj_unit) if(_target == other.id) _target = -1;   // they lose sight of him
                    unit_mana(id, -_teleport_cost);
                    _teleport_cooldown = _teleport_cooldown_time;
                    exit;
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
                // (gm-revive overrides) The drain shows: the victim is lifted off the ground and pales
                // as it goes on, with a red haze at its chest; a blood ribbon runs from it to his mouth
                // and his red glow flares each time it heals him (obj_boss draw; bats when it ends)
                if(_drain_victim != _target) {
                    vaelric_drain_end();
                    _drain_victim = _target;
                    _drain_taken = 0;
                    // his fangs go straight through shields (Power Word: Shield, Mana Shield and the like)
                    if(_target._absorbamount > 0) {
                        _target._absorbamount = 0; _target._absorbmax = 0;
                        repeat(5) { p = fx_make(3, _target.x, _target.y, _target.sprite_height * 0.5, make_color_rgb(150, 200, 255), 0.4, 18); }
                    }
                    _drain_y0 = _target.y;
                    _drain_blend0 = _target._blendcolor;
                    with(instance_create(_target.x, _target.y, obj_fx_aura)) { _master = other._target; _kind = 9; _src = other.id; }
                }
                var dk;
                dk = 1 - _attackcastwait / max(1, _attackcasttime);
                _target.y = _drain_y0 - 5 * min(1, dk * 5);
                _target._blendcolor = merge_color(_drain_blend0, make_color_rgb(185, 165, 190), round(min(1, dk * 1.5) * 5) / 5);
                // (gm-revive overrides) The drain quickens as it goes: slow at first, and almost half of
                // it in the last second (same 360 in all), so there's time to save the victim
                unit_damage(_target, c_yellow, (_bloodsuck_amount / _bloodsuck_casttime) * (0.4 + 1.8 * dk * dk), true);
                // Anyone it kills rises as his thrall
                if(_target._health <= 0 || _target.dead) {
                    p = _target;
                    _target._stunned = false;
                    vaelric_drain_end();
                    vaelric_raise(p);
                    _target = id;
                    _attackcastwait = -1;
                }
                // Enough damage to him while he feeds breaks the drain
                else if(_drain_taken >= _maxhealth * _drain_break_frac) {
                    vaelric_drain_break("broken");
                    exit;
                }
                else if(_attackcastwait mod (room_speed / 2) == 0) {
                    // (gm-revive overrides) Each sip heals him: 1.5% of his health over the whole drain (it was
                    // 4x the damage, 1,440 in all: under 1% of him now he's a raid boss), so stopping it matters
                    unit_heal(id, max((_bloodsuck_amount / (_bloodsuck_casttime / (room_speed / 2))) * 4, _maxhealth * 0.015 / (_bloodsuck_casttime / (room_speed / 2))));
                    _drain_pulse = 12;
                    p = fx_make(0, x, y, sprite_height * 0.55, make_color_rgb(170, 0, 20), 0.9, 14); p._add = false; p._grow = 1.5;
                    repeat(3) { p = fx_make(0, x + random_range(-8, 8), y, sprite_height * random_range(0.6, 0.9), make_color_rgb(200, 10, 30), 0.2, 16); p._add = false; p._vh = -0.8; p._grow = 0.6; }
                }
                if(_target != id) if(!_target._stunimmune && !unit_divine(_target)) {
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
                vaelric_drain_end();
                repeat(6) with(instance_create(x, y, obj_fx_bat)) _ang = random(360);
                unit_mana(id, -_bloodsuck_cost);
                create_text_effect(x, y, c_white, "-blood suck ends-");
                fs_note("Blood Sucks drunk to the end");
                _bloodsuck_cooldown = _bloodsuck_cooldown_time;
                _casting = false;
                _bloodsuck_casting = false;
                _target = id;
                exit;
            }
        }
    }
}