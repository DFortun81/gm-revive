// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
// unit_lists_populate();
// Populates the Ally, Enemy, Target, and Healer lists
//////////////////////////////////////////////////////
// Generate potential lists of units
ds_list_clear(_allylist);
ds_list_clear(_healerlist);
ds_list_clear(_targetlist);
ds_list_clear(_enemylist);

with(obj_unit) {
    if(!dead) {
        dist = unit_dist(id, other);
        if(dist < other._sightdistance) {
            if(_faction != other._faction) {
                if((!_stealthed || (_stealthed && dist < _stealthed_visibility)) && !_vanish_active) {
                    ds_list_add(other._enemylist, id);
                    if(_target == other.id) ds_list_add(other._targetlist, id);
                }
            }
            else {
                ds_list_add(other._allylist, id);
                if(_manatype == manatype_mana) {
                    if(_canheal && ((_manatype_mana / _manatype_maxmana) > 0.1)) {
                        ds_list_add(other._healerlist, id);
                    }
                }
            }
        }
    }
}