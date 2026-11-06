// match_load();
// Sets up the match record (once per session) and loads what earlier sessions saved in
// battlefield_matches.ini (kept in the browser's storage by the html5 runtime).
////////////////////////////////////////////////////////////////////////////////////////////
var i;
global.match_count = 0;
global.match_format = -1;
global.match_recent_n = 0;
global.match_clear_armed = 0;
ini_open("battlefield_matches.ini");
global.match_count = ini_read_real("totals", "matches", 0);
for(i = 0; i < 6; i += 1) {
    global.match_fmt_a[i] = ini_read_real("format" + string(i), "alliance", 0);
    global.match_fmt_h[i] = ini_read_real("format" + string(i), "horde", 0);
    global.match_fmt_d[i] = ini_read_real("format" + string(i), "draw", 0);
}
for(i = 0; i < 8; i += 1) {
    global.match_cls_units[i] = ini_read_real("classes", "units" + string(i), 0);
    global.match_cls_wins[i] = ini_read_real("classes", "wins" + string(i), 0);
}
global.boss_best = ini_read_real("boss", "best", 0);
global.boss_time = ini_read_real("boss", "kill_time_total", 0);
for(i = 0; i < 8; i += 1) {
    global.boss_cls_dmg[i] = ini_read_real("boss", "damage" + string(i), 0);
    global.boss_cls_heal[i] = ini_read_real("boss", "healing" + string(i), 0);
    global.boss_cls_secs[i] = ini_read_real("boss", "unit_seconds" + string(i), 0);
}
global.match_recent_n = ini_read_real("recent", "count", 0);
for(i = 0; i < 8; i += 1) {
    global.match_recent[i] = ini_read_string("recent", "line" + string(i), "");
    global.match_recent2[i] = ini_read_string("recent", "comp" + string(i), "");
}
ini_close();
