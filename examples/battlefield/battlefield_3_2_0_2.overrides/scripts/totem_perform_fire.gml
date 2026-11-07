// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
// totem_perform_fire(id);
// Attempts to perform as a fire totem of type id of 'id'
//////////////////////////////////////////////////////////////////
switch(argument0) {
    case totem_id_magma:
    {
        // Damages nearby unfriendly targets
        if(_duration mod room_speed == 0) {
            with(obj_unit) {
                if(_faction != other._faction) {
                    if(unit_dist(id, other) < range_totem) {
                        with(other._master) unit_damage(other.id, c_yellow, _totem_fire_magma_amount);
                    }
                }
            }
        }
    }
    break;
}