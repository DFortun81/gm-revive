// match_boss_rate(jobclass, healing);
// Damage (healing if the second argument is true) per unit per second against Stitchgut.
////////////////////////////////////////////////////////////////////////////////////////////
if(global.boss_cls_secs[argument0] <= 0) return -1;
if(argument1) return global.boss_cls_heal[argument0] / global.boss_cls_secs[argument0];
return global.boss_cls_dmg[argument0] / global.boss_cls_secs[argument0];
