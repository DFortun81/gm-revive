// raid_threat(unit, amount, is_healing);
// Adds threat on the current raid boss (global.raid_boss) for a unit that damaged it, or healed while
// it's up. Tanks make more: Warriors and Bear Druids 3x, Paladins 2x; healing counts half.
////////////////////////////////////////////////////////////////////////////////////////////
var u, m;
u = argument0;
if(!variable_global_exists("raid_boss")) exit;
if(!instance_exists(global.raid_boss) || !units_exists(u)) exit;
if(argument2) m = 0.5;
else {
    m = 1;
    if(u._jobclass == class_warrior) m = 3;
    else if(u._jobclass == class_druid) { if(u._shapeshift_form == druid_form_bear) m = 3; }
    else if(u._jobclass == class_paladin) m = 2;
}
u._raid_threat += argument1 * m;
