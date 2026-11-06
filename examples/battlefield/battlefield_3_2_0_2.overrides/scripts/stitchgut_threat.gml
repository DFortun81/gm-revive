// stitchgut_threat(unit, amount, is_healing);
// Adds threat on Stitchgut for a unit that damaged it (or healed while it's up). Tanks make more:
// Warriors and Bear Druids 3x, Paladins 2x; healing counts half, split evenly isn't modelled.
////////////////////////////////////////////////////////////////////////////////////////////
var u, m;
u = argument0;
if(!variable_global_exists("stitchgut")) exit;
if(!instance_exists(global.stitchgut) || !units_exists(u)) exit;
if(argument2) m = 0.5;
else {
    m = 1;
    if(u._jobclass == class_warrior) m = 3;
    else if(u._jobclass == class_druid) { if(u._shapeshift_form == druid_form_bear) m = 3; }
    else if(u._jobclass == class_paladin) m = 2;
}
u._stitch_threat += argument1 * m;
