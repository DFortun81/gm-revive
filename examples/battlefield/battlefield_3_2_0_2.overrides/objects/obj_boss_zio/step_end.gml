// Zio (gm-revive overrides: the game's own end step, with the Call to Arms version of the fight and a
// Magic Barrier that only holy power really breaks, like the Psycho Wand in Phantasy Star IV):
//  * Magic Barrier: once Dark Force is with him, a barrier worth _barrier_fraction of his health. Ordinary
//    damage hits it at 15% strength, holy damage (Paladins, Healers) at four times (unit_damage).
//    When it breaks he's exposed for _magicbarrier_cooldown_time, then Dark Force raises it again.
//  * Black Wave leaves a curse that hurts every second until the unit is healed to full (obj_unit).
//  * Hewn throws the units it hits back, in a vortex of dust and debris.
event_inherited();

if(dead) exit;
if(!variable_local_exists("_barrier_up")) {
    _barrier_up = false;
    _barrier_fraction = 0.04;
    // He's a raid boss for the whole field (40 units or more): health per unit on it, set here so it can
    // be tuned (the game's create event gives him 6,000 a unit)
    _health_per_unit = 2600;
    _maxhealth = _health_per_unit * instance_number(obj_unit);
    _health = _maxhealth;
    _magicbarrier_cooldown_time = room_speed * 30; // exposed this long after it breaks
    _blackwave_curse = 8;                          // the curse's damage per second
    _hewn_push = 28;
    _hewn_cooldown_time = room_speed * 8; // as in Call to Arms (the game's was 4 s, which shredded a raid)
    _last_holy = 0;
}
// The barrier broke
if(_barrier_up && _absorbamount <= 0) {
    _barrier_up = false;
    _magicbarrier_cooldown = _magicbarrier_cooldown_time;
    _message = "My barrier...! Impossible!";
}

// Decrement Cooldowns
_blackwave_cooldown -= 1;
_magicbarrier_cooldown -= 1;
_nightmare_cooldown -= 1;
_hewn_cooldown -= 1;
_corrsion_cooldown -= 1;

if(global.toggle_pause) exit;
if(global.cutscene_active || global.cutscene_ending) exit;

ds_list_clear(_enemylist);
with(obj_unit) {
    if(_faction != other._faction && !dead) {
        ds_list_add(other._enemylist, id);
    }
}

// Make sure to summon Dark Force (But only if someone is around.)
var size, aoesize, i, j, index; size = ds_list_size(_enemylist);
if(!instance_exists(obj_boss_darkforce) && size > 0) {
    // Zio Special Ability: Nightmare
    // Summons Dark Force to aid him in battle
    if(_manatype_mana >= _nightmare_manacost) {
        if(_attackcastwait == 0) sound_play(snd_summon);
        _attackcasttime = _nightmare_casttime;
        _attackcastwait += cast_delay();
        
        if(_attackcastwait < _attackcasttime) {
            // Still casting
            _destx = x;
            _desty = y;
            _message = "Nightmare.";
        }
        else {
            // Cast Successful
            with(instance_create(x, y, obj_boss_darkforce)) {
                _master = other.id;
            }
            unit_mana(id, -_nightmare_manacost);
            _attackcastwait = 0;
            _nightmare_cooldown = _nightmare_cooldown_time;
        }
        exit;
    }
}

if(!_casting) {
    // Zio Special Ability: Magic Barrier
    // Absorbs an amount of damage equal to 1% of Zio's maximum health
    if(!_barrier_up && _magicbarrier_cooldown < 0 && instance_exists(obj_boss_darkforce) && _manatype_mana >= _magicbarrier_manacost) {
        _barrier_up = true;
        _absorbmax = _maxhealth * _barrier_fraction;
        _absorbamount = _absorbmax;
        create_text_effect(x, y, c_white, "-magic barrier-");
        _message = "Dark Force shields me. Your blades are nothing!";
        unit_mana(id, -_magicbarrier_manacost);
        exit;
    }
    
    if(size <= 0) {
        _target = id;
        exit;
    }
    
    ds_list_clear(_aoelist);
    for(i = 0;i < size;i += 1) {
        index = ds_list_find_value(_enemylist, i);
        if(point_distance(x, y, index.x, index.y) < 250) {
            ds_list_add(other._aoelist, index);
        }
    }
    
    aoesize = ds_list_size(_aoelist);
    if(aoesize > 0) {
        // Zio Special Ability: Corrsion
        // Deals substantial magic damage to all enemies close to Zio
        // Also pulls enemies within 30 yards to Zio
        if(_corrsion_cooldown < 0 && _manatype_mana >= _corrsion_manacost) {
            _target = id;
            _casting = true;
            _corrsion_casting = true;
            _attackcasttime = _corrsion_casttime;
            _attackcastwait = 0;
            exit;
        }
        else {
            // Hewn is the part two of this attack
            // Zio Special Ability: Hewn
            // Does substantial damage to nearby units and knocks them back
            if(_hewn_cooldown < 0 && _manatype_mana >= _hewn_manacost) {
                _target = id;
                _casting = true;
                _hewn_casting = true;
                _attackcasttime = _hewn_casttime;
                _attackcastwait = 0;
                exit;
            }
        }   
    }
    
    // Zio Special Ability: Black Wave
    if(_blackwave_cooldown < 0 && _manatype_mana >= _blackwave_manacost) {
        _target = ds_list_find_value(_enemylist, random(ds_list_size(_enemylist) - 1));
        if(_target != -1 && instance_exists(_target)) {
            _casting = true;
            _blackwave_casting = true;
            _attackcasttime = _blackwave_casttime;
            _attackcastwait = 0;
            exit;
        }
    }
}
else {
    if((!instance_exists(_target) || _target.dead) || _target == id) {
        _target = -1;
        if(_blackwave_casting) {
            _casting = false;
            _attackcastwait = 0;
            _blackwave_casting = false;
            exit;
        }
    }
    
    // Continue casting
    if(_blackwave_casting) {
        // Zio Special Ability: Black Wave
        // Instantly damages a random enemy unit with the power of death
        // Requires the presence of Dark Force to use this ability
        _attackcasttime = _blackwave_casttime;
        _attackcastwait += 1;
        
        if(_attackcastwait < _attackcasttime) {
            // Still casting
            _destx = x;
            _desty = y;
            _message = "Black Wave.";
        }
        else {
            // Cast Successful
            var path, dir;
            path = path_add();
            dir = point_direction(x, y, _target.x, _target.y);
            path_add_point(path, x + cos(degtorad(dir)) * 10, y - sin(degtorad(dir)) * 10, sprite_height / 2);
            path_add_point(path, _target.x, _target.y, _target.sprite_height / 2);
            create_blackwave_effect(path);
            create_text_effect(x, y, c_white, "-black wave-");
            create_corrsion_effect(_target.x, _target.y, 20);
            unit_damage(_target, c_yellow, round(_blackwave_amount + random(_blackwave_amount) / 2));
            zio_curse(_target, _blackwave_curse);
            unit_mana(id, -_blackwave_manacost);
            sound_play(snd_blackwave);
            _attackcastwait = 0;
            _casting = false;
            _target = -1;
            _blackwave_casting = false;
            _blackwave_cooldown = _blackwave_cooldown_time;
            exit;
        }
    }
    
    if(_corrsion_casting) {
        // Zio Special Ability: Corrsion
        // Deals substantial magic damage to all enemies close to Zio
        // Also pulls enemies within 30 yards to Zio
        _attackcasttime = _corrsion_casttime;
        _attackcastwait += 1;
        
        if(_attackcastwait < _attackcasttime) {
            // Still casting
            _destx = x;
            _desty = y;
            _message = "Corrsion.";
        }
        else {
            // Cast Successful
            create_text_effect(x, y, c_white, "-corrsion-");
            
            ds_list_clear(_aoelist);
            for(i = 0;i < size;i += 1) {
                index = ds_list_find_value(_enemylist, i);
                if(point_distance(x, y, index.x, index.y) < 250) {
                    ds_list_add(other._aoelist, index);
                }
            }
            
            aoesize = ds_list_size(_aoelist);
            for(i = 0;i < aoesize; i += 1;) {
                _t = ds_list_find_value(other._aoelist, i);
                create_corrsion_effect(_t.x, _t.y, 10);
                unit_damage(_t, c_yellow, round(_corrsion_amount + random(_corrsion_amount) / 2));
            }
            
            unit_mana(id, -_corrsion_manacost);
            sound_play(snd_corrsion);
            _attackcastwait = 0;
            _casting = false;
            _target = -1;
            _corrsion_casting = false;
            _corrsion_cooldown = _corrsion_cooldown_time;
            exit;
        }
    }
    
    if(_hewn_casting) {
        // Zio Special Ability: Hewn
        // Does substantial damage to nearby units and knocks them back
        _attackcasttime = _hewn_casttime;
        _attackcastwait += 1;
        
        if(_attackcastwait < _attackcasttime) {
            // Still casting
            _destx = x;
            _desty = y;
            _message = "Hewn.";
        }
        else {
            // Cast Successful
            create_text_effect(x, y, c_white, "-hewn-");
            
            ds_list_clear(_aoelist);
            for(i = 0;i < size;i += 1) {
                index = ds_list_find_value(_enemylist, i);
                if(point_distance(x, y, index.x, index.y) < 250) {
                    ds_list_add(other._aoelist, index);
                }
            }
            
            aoesize = ds_list_size(_aoelist);
            for(i = 0;i < aoesize; i += 1;) {
                _t = ds_list_find_value(other._aoelist, i);
                create_hewn_effect(_t.x, _t.y, 10);
                unit_damage(_t, c_yellow, round(_hewn_amount + random(_hewn_amount) / 2));
                zio_hewn_push(_t, _hewn_push);
            }
            
            sound_play(snd_hewn);
            unit_mana(id, -_hewn_manacost);
            _attackcastwait = 0;
            _casting = false;
            _target = -1;
            _hewn_casting = false;
            _hewn_cooldown = _hewn_cooldown_time;
            exit;
        }
    }
}