// unit_hitbox(id);
// How far a unit's body reaches out from its centre (gm-revive overrides). Bosses have a hit box, as in
// Call to Arms, so melee can stand at their edge instead of right on top of them: 40% of the boss's
// sprite width, at least 12 (Zio 13, Count Vaelric 19, the Broodmother 26, the Lichcaller 32).
// Everyone else is 0, which keeps unit-to-unit distances as the 2013 game had them.
////////////////////////////////////////////////////////////////////////////////////////////
var h;
h = 0;
with(argument0) {
    if(!variable_local_exists("_hitbox")) {
        _hitbox = 0;
        if(object_index == obj_boss || object_is_ancestor(object_index, obj_boss)) _hitbox = max(12, round(sprite_width * 0.4));
    }
    h = _hitbox;
}
return h;
