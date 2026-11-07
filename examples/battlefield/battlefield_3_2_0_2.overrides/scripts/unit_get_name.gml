// unit_get_name(id);
// What to call a unit in the target boxes and the boss list (gm-revive overrides). job_get_name only
// knows the playable classes and the bosses, so Marquis Elmdor's Assassins and the Broodmother's
// broodlings showed up as "Unknown Entity". A unit with its own _name goes by it (Celia, Lede).
////////////////////////////////////////////////////////////////////////////////////////////
var u, n;
u = argument0;
n = "";
with(u) {
    if(variable_local_exists("_name")) n = _name;
    else if(object_index == obj_broodling) n = "Broodling";
    else if(_jobclass == class_mirrorimage) n = "Mirror Image";
    else n = job_get_name(_jobclass, _bossid);
}
return n;
