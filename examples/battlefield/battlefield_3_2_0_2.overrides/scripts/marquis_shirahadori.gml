// marquis_shirahadori(marquis, attacker, damage);
// Called by unit_damage when something hits Marquis Elmdor. Returns true if he catches the blow: a
// melee blow (a Warrior, Rogue, Paladin or Shaman, or a Druid in cat or bear form, swinging from close
// by) is caught _shirahadori_chance of the time. Spells, Fireballs and totems always land. A caught
// blow still counts for threat, so a tank keeps him even while he parries it.
// (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var b, a, melee;
b = argument0; a = argument1;
if(!instance_exists(a)) return false;
if(!object_is_ancestor(a.object_index, obj_unit)) return false;
if(point_distance(a.x, a.y, b.x, b.y) > range_melee * 1.6) return false;
melee = false;
switch(a._jobclass) {
    case class_warrior: case class_rogue: case class_paladin: case class_shaman: melee = true; break;
    case class_druid: melee = (a._shapeshift_form != druid_form_normal); break;
}
if(!melee || random(1) >= b._shirahadori_chance) return false;
b._caught += 1;
raid_threat(a, argument2, false);
if(current_time - b._last_caught > 400) {
    b._last_caught = current_time;
    create_text_effect(b.x, b.y, c_white, "-shirahadori-");
    with(fx_make(6, b.x, b.y, b.sprite_height * 0.55, c_white, 0.4, 10)) _spin = 25;
}
return true;
