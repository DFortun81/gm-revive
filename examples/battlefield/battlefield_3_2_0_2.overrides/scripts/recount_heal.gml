// recount_heal(source, target, amount);
// Called by unit_heal with the effective healing (overhealing doesn't count). Heal-over-time ticks
// run in the target's own step, so they set global._recount_hot_job (job + 1, so 0 means none)
// to say which class cast them.
////////////////////////////////////////////////////////////////////////////////////////////
var o;
if(argument2 <= 0 || !instance_exists(argument1)) exit;
if(global._recount_hot_job > 0) {
    recount_add(global._recount_healing_done, global._recount_hot_job - 1, argument1._faction, argument2);
}
else {
    o = recount_owner(argument0);
    if(o != -1) {
        recount_add(global._recount_healing_done, o._jobclass, o._faction, argument2);
        fs_add(global.fs_heal, o, argument2);
        raid_threat(o, argument2, true);
    }
}
if(argument1._jobclass != class_mirrorimage && argument1._bossid == -1) {
    recount_add(global._recount_healing_taken, argument1._jobclass, argument1._faction, argument2);
}
