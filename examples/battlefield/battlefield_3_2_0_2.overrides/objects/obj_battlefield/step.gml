// (gm-revive overrides) automatic matches: detect the end, record it, reset
match_step();
// (gm-revive overrides) While Zio or Count Vaelric is on the field, the Horde's totems fight with the
// Alliance against him like their Shamans do (see obj_unit's begin step), and go back afterwards
if(instance_exists(obj_boss_zio) || instance_exists(obj_boss_elmdor)) {
    with(obj_totem) if(_faction == "Horde") { _common_faction = "Horde"; _faction = "Alliance"; }
}
else {
    with(obj_totem) if(variable_local_exists("_common_faction")) { if(_common_faction != "") { _faction = _common_faction; _common_faction = ""; } }
}
