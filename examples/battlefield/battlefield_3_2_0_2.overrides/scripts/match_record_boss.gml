// match_record_boss();
// Called by match_record at the end of a Boss match: adds each class's damage and healing (from the
// damage meter) and its unit-seconds (units of that class x fight length), so the results panel can
// show damage and healing per unit per second. Kill times feed the best and average kill.
////////////////////////////////////////////////////////////////////////////////////////////
var j, f, secs, d, h, l;
secs = global.match_steps / room_speed;
if(global.match_winner == "Alliance") {
    global.boss_time += secs;
    if(global.boss_best <= 0 || secs < global.boss_best) global.boss_best = secs;
}
for(j = 0; j < 8; j += 1) {
    if(j == class_mirrorimage || global.match_comp_a[j] <= 0) continue;
    d = 0; h = 0;
    l = ds_list_find_value(global._recount_damage_done, j);
    for(f = 0; f < ds_list_size(l); f += 1) d += ds_list_find_value(l, f);
    l = ds_list_find_value(global._recount_healing_done, j);
    for(f = 0; f < ds_list_size(l); f += 1) h += ds_list_find_value(l, f);
    global.boss_cls_dmg[j] += d;
    global.boss_cls_heal[j] += h;
    global.boss_cls_secs[j] += global.match_comp_a[j] * secs;
}
