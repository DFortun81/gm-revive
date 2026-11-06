// match_save();
// Writes the match record to battlefield_matches.ini.
////////////////////////////////////////////////////////////////////////////////////////////
var i, b, sec;
ini_open("battlefield_matches.ini");
ini_write_real("totals", "matches", global.match_count);
for(i = 0; i < 6; i += 1) {
    ini_write_real("format" + string(i), "alliance", global.match_fmt_a[i]);
    ini_write_real("format" + string(i), "horde", global.match_fmt_h[i]);
    ini_write_real("format" + string(i), "draw", global.match_fmt_d[i]);
}
for(i = 0; i < 8; i += 1) {
    ini_write_real("classes", "units" + string(i), global.match_cls_units[i]);
    ini_write_real("classes", "wins" + string(i), global.match_cls_wins[i]);
}
ini_section_delete("boss"); // the old single-boss section (now boss0)
for(b = 0; b < 3; b += 1) {
    sec = "boss" + string(b);
    ini_write_real(sec, "kills", global.boss_kills[b]);
    ini_write_real(sec, "wipes", global.boss_wipes[b]);
    ini_write_real(sec, "best", global.boss_best[b]);
    ini_write_real(sec, "kill_time_total", global.boss_time[b]);
    ini_write_real(sec, "extra", global.boss_extra[b]);
    ini_write_real(sec, "extra2", global.boss_extra2[b]);
    for(i = 0; i < 8; i += 1) {
        ini_write_real(sec, "damage" + string(i), global.boss_cls_dmg[b * 8 + i]);
        ini_write_real(sec, "healing" + string(i), global.boss_cls_heal[b * 8 + i]);
        ini_write_real(sec, "unit_seconds" + string(i), global.boss_cls_secs[b * 8 + i]);
    }
}
ini_write_real("recent", "count", global.match_recent_n);
for(i = 0; i < 8; i += 1) {
    ini_write_string("recent", "line" + string(i), global.match_recent[i]);
    ini_write_string("recent", "comp" + string(i), global.match_recent2[i]);
}
ini_close();
