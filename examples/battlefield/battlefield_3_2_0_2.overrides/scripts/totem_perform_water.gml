// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
// totem_perform_water(id);
// Attempts to perform as a water totem of type id of 'id'
//////////////////////////////////////////////////////////////////
switch(argument0) {
    case totem_id_healingstream:
    {
        // Heal nearby friendly targets
        if(_duration mod (room_speed * 5) == 0) {
            create_text_effect(x, y, c_white, "-healing stream-");
            with(obj_unit) {
                if(_faction == other._faction) {
                    if(unit_dist(id, other) < range_totem) {
                        with(other._master) unit_heal(other.id, other._maxhealth * 0.01);
                    }
                }
            }
        }
    }
    break;
    case totem_id_manaspring:
    {
        // Restore Mana of nearby friendly targets
        if(_duration mod (room_speed * 5) == 0) {
            create_text_effect(x, y, c_white, "-mana spring-");
            with(obj_unit) {
                if(_faction == other._faction && _manatype == manatype_mana) {
                    if(unit_dist(id, other) < range_totem) {
                        _manaspring_tick_timer = room_speed * 5;
                    }
                }
            }
        }
    }
    break;
    case totem_id_manatide:
    {
        // Restore 10% Mana of nearby friendly targets
        if(_duration mod (room_speed * 3) == 0) {
            create_text_effect(x, y, c_white, "-mana tide-");
            with(obj_unit) {
                if(_faction == other._faction && _manatype == manatype_mana) {
                    if(unit_dist(id, other) < range_totem) {
                        with(other._master) unit_mana(other.id, other._manatype_maxmana * 0.10);
                        create_text_effect(x, y, c_blue, string(_manatype_maxmana * 0.10));
                    }
                }
            }
        }
    }
    break;
}