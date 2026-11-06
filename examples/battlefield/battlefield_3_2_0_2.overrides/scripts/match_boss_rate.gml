// match_boss_rate(boss, jobclass, healing);
// Damage (healing if the third argument is true) per unit per second against that raid boss, or -1.
////////////////////////////////////////////////////////////////////////////////////////////
var k;
k = argument0 * 8 + argument1;
if(global.boss_cls_secs[k] <= 0) return -1;
if(argument2) return global.boss_cls_heal[k] / global.boss_cls_secs[k];
return global.boss_cls_dmg[k] / global.boss_cls_secs[k];
