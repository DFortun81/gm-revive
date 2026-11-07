// (gm-revive overrides) the game's own code, with distances between units measured edge to edge
// (unit_dist: bosses have a hit box, so melee can stand at their edge instead of on top of them)
// totem_perform_wind(id);
// Attempts to perform as a wind totem of type id of 'id'
//////////////////////////////////////////////////////////////////
switch(argument0) {
    case totem_id_windfury:
    {
        // Increase Melee Haste of nearby friendly targets
        // Increases Spell Haste of nearby friendly units
        // Increases Spell Damage by 10.
    }
    break;
    case totem_id_windshear:
    {
        // Interupts nearby unfriendly targets
        if(_duration == 0) {
            create_text_effect(x, y, c_white, "-wind shear-");
            with(obj_unit) {
                if(_faction != other._faction && !_interuptimmune) {
                    if(_attackcastwait <= 0) continue;
                    if(unit_dist(id, other) < range_totem) {
                        _attackcastwait = 0;
                        create_text_effect(x, y, c_yellow, "---");
                    }
                }
            }
        }
    }
    break;
}