// match_comp_string(side);
// The current match's composition for one side (0 = Alliance, 1 = Horde), e.g. "2War Hea Rog".
////////////////////////////////////////////////////////////////////////////////////////////
var c, n, s;
s = "";
for(c = 0; c < 8; c += 1) {
    if(c == class_mirrorimage) continue;
    if(argument0 == 0) n = global.match_comp_a[c]; else n = global.match_comp_h[c];
    if(n > 0) {
        if(s != "") s += " ";
        if(n > 1) s += string(n);
        s += match_class_abbrev(c);
    }
}
return s;
