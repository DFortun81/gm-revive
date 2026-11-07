// recount_owner(instance);
// Works out which unit should be credited for something an instance did: a Caster for its
// Fireballs and Mirror Images, a Shaman for its totems, the unit itself otherwise.
// Returns -1 for bosses and anything that can't be traced back to a unit.
////////////////////////////////////////////////////////////////////////////////////////////
var s;
s = argument0;
if(!instance_exists(s)) return -1;
if(s.object_index == obj_fireball) {
    // _source is set by the Caster when it throws the Fireball
    if(instance_exists(s._source)) return s._source;
    return -1;
}
if(s.object_index == obj_frostbolt) {
    // (gm-revive overrides) a wand bolt (unit_fallback) knows who fired it; the bosses' bolts don't
    if(instance_exists(s._source)) return recount_owner(s._source);
    return -1;
}
if(s.object_index == obj_mirror_image) {
    if(instance_exists(s._master)) return s._master;
    return -1;
}
if(s.object_index == obj_totem || object_is_ancestor(s.object_index, obj_totem)) {
    if(instance_exists(s._master)) return s._master;
    return -1;
}
if(object_is_ancestor(s.object_index, obj_unit)) {
    if(s._bossid != -1) return -1;
    return s;
}
return -1;
