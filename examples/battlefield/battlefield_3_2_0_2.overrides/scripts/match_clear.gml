// match_clear();
// Forgets every recorded match (also in the saved file).
////////////////////////////////////////////////////////////////////////////////////////////
var i;
global.match_count = 0;
global.match_recent_n = 0;
for(i = 0; i < 5; i += 1) {
    global.match_fmt_a[i] = 0;
    global.match_fmt_h[i] = 0;
    global.match_fmt_d[i] = 0;
}
for(i = 0; i < 8; i += 1) {
    global.match_cls_units[i] = 0;
    global.match_cls_wins[i] = 0;
    global.match_recent[i] = "";
    global.match_recent2[i] = "";
}
match_save();
