// unit_heal(id, damage);
// (gm-revive overrides: same as the original, plus effective healing is reported to recount_heal)
//////////////////////////////////
var before;
if(instance_exists(argument0)) {
    before = argument0._health;
    argument0._health = max(0, min(argument0._maxhealth, argument0._health + argument1));
    create_text_effect(argument0.x, argument0.y, c_green, string(argument1));
    recount_heal(id, argument0, argument0._health - before);
}
