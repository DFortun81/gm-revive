// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
if(global.toggle_pause) exit;

if(dead) exit;
if(_polymorphed) {
    // Reset all Unique spell cooldowns
    _attackcastwait = 0;
    event_inherited();
    exit;
}

if(global.cutscene_active && global.cutscene_focus != id) {
    _target = global.cutscene_focus;
    
    // What image are we using (based on subindex and sheet)
    _direction = point_direction(x, y, _target.x, _target.y);
    _dir = deg_to_dir(_direction);
    image_single = _dir * 4;
    exit;
}

var dist, dir, maxdist, maxhp, priority;
// Generate potential lists of units
unit_lists_populate();

var allies, enemies, healer_count, target_amount, i, index;
allies = ds_list_size(_allylist);
enemies = ds_list_size(_enemylist);
healer_count = ds_list_size(_healerlist);
target_amount = ds_list_size(_targetlist);

if(ds_list_find_index(_enemylist, _target) >= 0) {
    dist = unit_dist(id, _target);
    if(dist >= _attackrange) {
        // Move into our attack range
        _attackcastwait = 0;
        dir = point_direction(x, y, _target.x, _target.y);
        _dir = deg_to_dir(dir);
        _destx = round(x + cos(degtorad(dir)) * _movespeed);
        _desty = round(y - sin(degtorad(dir)) * _movespeed);
        
        _subindex += 0.1;
        move_towards_point_ext(_destx, _desty, _movespeed);
        
        image_single = _dir * 4 + floor(_subindex mod 4);
        depth = -y;
        exit;
    }
    else {
        // Attack!
        if(_target._polymorphed) _target = -1;
        else {
            _attackcastwait += 1;
            if(_attackcastwait >= _attackcasttime) {
                // Damage time!
                unit_damage(_target, c_yellow, _attackdamage);
                with(instance_create(x, y, obj_fireball)) {
                    _master = other._target;
                    _x = other._target.x;
                    _y = other._target.y;
                    _attackdamage = other._attackdamage;
                }
                _attackcastwait = 0;
            }
        }
    }
}
else {
    _attackcastwait = 0;
    
    priority = 99;
    maxhp = 999999;
    maxdist = 99999;
    for(i = 0;i < enemies; i += 1) {
        with(ds_list_find_value(_enemylist, i)) {
            if(!_polymorphed) {
                dist = unit_dist(id, other);
                if(priority > 6 || (priority == 6 && (dist < maxdist || (_health < maxhp)))) {
                    priority = 6;
                    maxdist = dist;
                    maxhp = _health;
                    other._target = id;
                }
            }
        }
    }  
    
    if(!units_exists(_target)) {
        if(units_exists(_master)) {
            // Follow my master.
            _destx = _master.x + cos(degtorad(_master._direction + _angle)) * 16;
            _desty = _master.y - sin(degtorad(_master._direction + _angle)) * 16;
            dir = point_direction(x, y, _destx, _desty);
            _dir = deg_to_dir(dir);
            
            if(round(_destx) != round(x) || round(_desty) != round(y)) {
                _subindex += 0.1;
                move_towards_point_ext(_destx, _desty, _movespeed);
            }
            else _subindex = 0;
            
            image_single = _dir * 4 + floor(_subindex mod 4);
            depth = -y;
            exit;
        }
        else {
            // Find my own since my master appears to be dead... :(
            // Anyone moving towards something within my sight?
            for(i = 0;i < allies;i += 1) {
                with(ds_list_find_value(_allylist, i)) {
                    if(ds_list_find_index(other._enemylist, _target) >= 0) {
                        if(_destx != x || _desty != y) {
                            other._destx = _destx;
                            other._desty = _desty;
                            break;
                        }
                    }
                }
            }
            
            // Still nothing? Just go somewhere that's not here!
            if(_destx == x && _desty == y) {
                // Go searching for something to kill on our own
                _destx = round(_sightdistance / 2 + random(room_width - _sightdistance));
                _desty = round(_sightdistance / 2 + random(room_height - _sightdistance));
            }
        }
    }         
}

event_inherited(); 
