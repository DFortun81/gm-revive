// match_clear();
// Forgets every recorded match (also in the saved file).
////////////////////////////////////////////////////////////////////////////////////////////
var i;
global.match_count = 0;
global.match_recent_n = 0;
for(i = 0; i < 6; i += 1) {
    global.match_fmt_a[i] = 0;
    global.match_fmt_h[i] = 0;
    global.match_fmt_d[i] = 0;
}
for(i = 0; i < global.raid_boss_count; i += 1) {
    global.boss_kills[i] = 0;
    global.boss_wipes[i] = 0;
    global.boss_best[i] = 0;
    global.boss_time[i] = 0;
    global.boss_extra[i] = 0;
    global.boss_extra2[i] = 0;
}
for(i = 0; i < global.raid_boss_count * 8; i += 1) {
    global.boss_cls_dmg[i] = 0;
    global.boss_cls_heal[i] = 0;
    global.boss_cls_secs[i] = 0;
}
for(i = 0; i < 8; i += 1) {
    global.match_cls_units[i] = 0;
    global.match_cls_wins[i] = 0;
    global.match_recent[i] = "";
    global.match_recent2[i] = "";
}
match_save();
