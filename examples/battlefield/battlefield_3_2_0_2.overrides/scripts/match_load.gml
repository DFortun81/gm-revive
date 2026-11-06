// match_load();
// Sets up the match record (once per session) and loads what earlier sessions saved in
// battlefield_matches.ini (kept in the browser's storage by the html5 runtime).
////////////////////////////////////////////////////////////////////////////////////////////
var i, b, sec;
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
// Raid bosses: 0 Stitchgut, 1 Lichcaller, 2 Broodmother. Saves from before there were three keep
// Stitchgut's numbers in the [boss] section; they are read as boss 0.
for(b = 0; b < 3; b += 1) {
    sec = "boss" + string(b);
    if(b == 0 && !ini_section_exists("boss0")) sec = "boss";
    global.boss_kills[b] = ini_read_real(sec, "kills", 0);
    global.boss_wipes[b] = ini_read_real(sec, "wipes", 0);
    if(sec == "boss") { global.boss_kills[b] = global.match_fmt_a[5]; global.boss_wipes[b] = global.match_fmt_h[5]; }
    global.boss_best[b] = ini_read_real(sec, "best", 0);
    global.boss_time[b] = ini_read_real(sec, "kill_time_total", 0);
    global.boss_extra[b] = ini_read_real(sec, "extra", 0);
    global.boss_extra2[b] = ini_read_real(sec, "extra2", 0);
    for(i = 0; i < 8; i += 1) {
        global.boss_cls_dmg[b * 8 + i] = ini_read_real(sec, "damage" + string(i), 0);
        global.boss_cls_heal[b * 8 + i] = ini_read_real(sec, "healing" + string(i), 0);
        global.boss_cls_secs[b * 8 + i] = ini_read_real(sec, "unit_seconds" + string(i), 0);
    }
}
global.match_recent_n = ini_read_real("recent", "count", 0);
for(i = 0; i < 8; i += 1) {
    global.match_recent[i] = ini_read_string("recent", "line" + string(i), "");
    global.match_recent2[i] = ini_read_string("recent", "comp" + string(i), "");
}
ini_close();
