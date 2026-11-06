// match_save();
// Writes the match record to battlefield_matches.ini.
////////////////////////////////////////////////////////////////////////////////////////////
var i;
ini_open("battlefield_matches.ini");
ini_write_real("totals", "matches", global.match_count);
for(i = 0; i < 5; i += 1) {
    ini_write_real("format" + string(i), "alliance", global.match_fmt_a[i]);
    ini_write_real("format" + string(i), "horde", global.match_fmt_h[i]);
    ini_write_real("format" + string(i), "draw", global.match_fmt_d[i]);
}
for(i = 0; i < 8; i += 1) {
    ini_write_real("classes", "units" + string(i), global.match_cls_units[i]);
    ini_write_real("classes", "wins" + string(i), global.match_cls_wins[i]);
}
ini_write_real("recent", "count", global.match_recent_n);
for(i = 0; i < 8; i += 1) {
    ini_write_string("recent", "line" + string(i), global.match_recent[i]);
    ini_write_string("recent", "comp" + string(i), global.match_recent2[i]);
}
ini_close();
