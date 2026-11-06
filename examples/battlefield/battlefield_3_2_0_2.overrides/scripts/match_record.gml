// match_record();
// Adds the match that just ended to the record and saves it.
////////////////////////////////////////////////////////////////////////////////////////////
var f, c, i, w, line, comp;
f = global.match_format;
w = global.match_winner;
global.match_count += 1;
if(w == "Alliance") global.match_fmt_a[f] += 1;
else if(w == "Horde") global.match_fmt_h[f] += 1;
else global.match_fmt_d[f] += 1;

// Class win rate: of all the units of a class that fought (in random-class matches with a winner),
// how many were on the winning side
if(f > 0 && w != "") {
    for(c = 0; c < 8; c += 1) {
        global.match_cls_units[c] += global.match_comp_a[c] + global.match_comp_h[c];
        if(w == "Alliance") global.match_cls_wins[c] += global.match_comp_a[c];
        else global.match_cls_wins[c] += global.match_comp_h[c];
    }
}

line = "Match " + string(global.match_count) + ":  " + match_format_name(f) + ",  "; // (no "#": GM draws it as a line break)
if(w == "") line += "draw (time limit)";
else line += w + " won";
line += " in " + string(floor(global.match_steps / room_speed)) + "s";
comp = "";
if(f > 0) {
    if(w == "Horde") comp = "Horde " + match_comp_string(1) + "  beat  Alliance " + match_comp_string(0);
    else if(w == "Alliance") comp = "Alliance " + match_comp_string(0) + "  beat  Horde " + match_comp_string(1);
    else comp = "Alliance " + match_comp_string(0) + "  vs  Horde " + match_comp_string(1);
}

for(i = 7; i > 0; i -= 1) {
    global.match_recent[i] = global.match_recent[i - 1];
    global.match_recent2[i] = global.match_recent2[i - 1];
}
global.match_recent[0] = line;
global.match_recent2[0] = comp;
global.match_recent_n = min(8, global.match_recent_n + 1);
match_save();
