// unit_is_casting(id);
// True if the unit is in the middle of a spell with a cast time that Kick can interrupt.
// (Warriors and Rogues reuse _attackcastwait for other things, so they never count.)
////////////////////////////////////////////////////////////////////////////////////////////
var u;
u = argument0;
if(!units_exists(u)) return false;
if(u.dead || u._attackcastwait <= 0) return false;
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
