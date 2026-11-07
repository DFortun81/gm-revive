// unit_is_casting(id);
// True if the unit is in the middle of a spell with a cast time that Kick can interrupt.
// (Warriors and Rogues reuse _attackcastwait for other things, so they never count.)
////////////////////////////////////////////////////////////////////////////////////////////
var u;
u = argument0;
if(!units_exists(u)) return false;
if(u.dead || u._attackcastwait <= 0) return false;
// (gm-revive overrides) Count Vaelric: Blood Suck can be stopped (nothing else he casts can), but only
// once he's lost in the feeding, in its second half; until then he's on guard
if(u.object_index == obj_boss_elmdor) return (u._bloodsuck_casting && u._attackcastwait <= u._attackcasttime * u._drain_guard);
// Raid bosses say for themselves which casts can be stopped
if(object_is_ancestor(u.object_index, obj_boss_raid)) return (u._raid_casting && !u._interuptimmune);
switch(u._jobclass) {
    case class_healer:
    case class_caster:
    case class_shaman:
    case class_paladin:
        return true;
    case class_druid:
        return (u._shapeshift_form == druid_form_normal);
}
return false;
