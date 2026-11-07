// unit_heal(id, damage);
// (gm-revive overrides: same as the original, plus effective healing is reported to recount_heal, and
// healing on someone Count Vaelric is draining with Blood Suck is halved: the blood won't stay)
//////////////////////////////////
var before, h, tgt;
if(instance_exists(argument0)) {
    h = argument1;
    tgt = argument0;
    with(obj_boss_elmdor) if(variable_local_exists("_drain_victim")) { if(_bloodsuck_casting && _drain_victim == tgt) h *= 0.5; }
    before = argument0._health;
    argument0._health = max(0, min(argument0._maxhealth, argument0._health + h));
    create_text_effect(argument0.x, argument0.y, c_green, string(round(h)));
    recount_heal(id, argument0, argument0._health - before);
}
