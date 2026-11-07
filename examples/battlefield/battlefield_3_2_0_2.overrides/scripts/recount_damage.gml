// recount_damage(source, target, amount);
// Called by unit_damage for every point of damage that got through. Credits the damage to the
// source's job and faction and records it as damage taken by the target's job and faction.
////////////////////////////////////////////////////////////////////////////////////////////
var o;
if(argument2 <= 0) exit;
o = recount_owner(argument0);
if(o != -1) {
    recount_add(global._recount_damage_done, o._jobclass, o._faction, argument2);
    if(instance_exists(argument1)) { if(argument1._faction != o._faction) fs_add(global.fs_dmg, o, argument2); }
    if(instance_exists(argument1)) { if(object_is_ancestor(argument1.object_index, obj_boss_raid)) raid_threat(o, argument2, false); }
}
if(instance_exists(argument1)) {
    if(argument1._jobclass != class_mirrorimage && argument1._bossid == -1) {
        recount_add(global._recount_damage_taken, argument1._jobclass, argument1._faction, argument2);
        fs_add(global.fs_taken, argument1, argument2);
    }
}
