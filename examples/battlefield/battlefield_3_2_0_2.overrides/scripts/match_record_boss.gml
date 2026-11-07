// match_record_boss();
// Called by match_record at the end of a Boss match: adds each class's damage and healing (from the
// damage meter) and its unit-seconds (units of that class x fight length) to that boss's record, so the
// results pages can show damage and healing per unit per second. Kill times feed the best and average
// kill; each boss also keeps two counts of its own (Lichcaller: interrupts and Dark Mendings that got
// through; Broodmother: broodlings killed and hatched; The Blighted: raid deaths and disease bursts).
////////////////////////////////////////////////////////////////////////////////////////////
var j, f, secs, d, h, l, b;
b = global.match_boss;
secs = global.match_steps / room_speed;
if(global.match_winner == "Alliance") {
    global.boss_kills[b] += 1;
    global.boss_time[b] += secs;
    if(global.boss_best[b] <= 0 || secs < global.boss_best[b]) global.boss_best[b] = secs;
}
else global.boss_wipes[b] += 1;
with(obj_boss_lichcaller) {
    global.boss_extra[1] += _kicks + _setbacks;
    global.boss_extra2[1] += _mends_landed;
}
with(obj_boss_marquis) {
    global.boss_extra[4] += _vamps;
    global.boss_extra2[4] += _caught;
}
with(obj_boss_ladyjane) {
    global.boss_extra[5] += _charges;
    global.boss_extra2[5] += _shouts;
}
with(obj_boss_broodmother) {
    global.boss_extra[2] += _broodlings_killed;
    global.boss_extra2[2] += _broodlings_hatched;
}
// The Blighted: raid deaths and disease bursts
if(b == 3) {
    with(obj_boss_blighted) global.boss_extra2[3] += _bursts;
    for(j = 0; j < 8; j += 1) global.boss_extra[3] += global.match_comp_a[j];
    with(obj_unit) if(_faction == "Alliance" && !dead && _jobclass != class_mirrorimage) global.boss_extra[3] -= 1;
}
for(j = 0; j < 8; j += 1) {
    if(j == class_mirrorimage || global.match_comp_a[j] <= 0) continue;
    d = 0; h = 0;
    l = ds_list_find_value(global._recount_damage_done, j);
    for(f = 0; f < ds_list_size(l); f += 1) d += ds_list_find_value(l, f);
    l = ds_list_find_value(global._recount_healing_done, j);
    for(f = 0; f < ds_list_size(l); f += 1) h += ds_list_find_value(l, f);
    global.boss_cls_dmg[b * 8 + j] += d;
    global.boss_cls_heal[b * 8 + j] += h;
    global.boss_cls_secs[b * 8 + j] += global.match_comp_a[j] * secs;
}
