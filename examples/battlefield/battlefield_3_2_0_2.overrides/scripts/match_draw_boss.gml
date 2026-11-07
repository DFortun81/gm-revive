// match_draw_boss(center_x, boss);
// A results page for one raid boss (0 Stitchgut ... 5 Lady Jane, see global.raid_boss_display): kills, wipes, kill
// times, the boss's own counts, and each class's damage and healing per unit per second against it.
////////////////////////////////////////////////////////////////////////////////////////////
var cx, b, w, h, x1, y1, row, i, j, best, used, v, top, s, fights, col, name, yy;
cx = argument0; b = argument1;
name = global.raid_boss_display[b];
w = 600; h = 22 + 16 * 23;
x1 = cx - w / 2; y1 = view_yview[0] + view_hview[0] / 2 - h / 2;
draw_set_alpha(.8);
draw_set_color(c_black);
draw_rectangle(x1, y1, x1 + w, y1 + h, false);
draw_window_skinned(x1, y1, x1 + w, y1 + h);
draw_set_alpha(1);
draw_set_halign(fa_left);
fights = global.boss_kills[b] + global.boss_wipes[b];
s = name + ": " + string(global.boss_kills[b]) + " kills, " + string(global.boss_wipes[b]) + " wipes";
if(global.boss_kills[b] > 0) s += ",  best kill " + string(round(global.boss_best[b])) + "s,  average " + string(round(global.boss_time[b] / global.boss_kills[b])) + "s";
if(global.match_over && global.match_format == 5 && global.match_boss == b) {
    if(global.match_winner == "Alliance") s = "Defeated!   " + s; else s = "Wiped!   " + s;
}
draw_set_color(c_white);
draw_text(x1 + 12, y1 + 10, s);
draw_set_halign(fa_right);
draw_text(x1 + w - 12, y1 + 10, "[5] next page");
draw_set_halign(fa_left);
draw_set_color(c_ltgray);
s = "";
if(b == 0) s = "Tank and spank: sustained single-target damage, healing and tanking";
if(b == 1) {
    s = "Interrupt check";
    if(fights > 0) s += ":  " + string_format(global.boss_extra[b] / fights, 1, 1) + " interrupts a fight (Kick, Wind Shear),  " + string_format(global.boss_extra2[b] / fights, 1, 1) + " Dark Mendings got through";
}
if(b == 3) {
    s = "Healing check";
    if(fights > 0) s += ":  " + string_format(global.boss_extra[b] / fights, 1, 1) + " raid deaths a fight,  " + string_format(global.boss_extra2[b] / fights, 1, 1) + " disease bursts";
}
if(b == 4) {
    s = "Duel: melee blows get caught, so casters carry it";
    if(fights > 0) s += ":  " + string_format(global.boss_extra2[b] / fights, 1, 1) + " blows caught (Shirahadori),  " + string_format(global.boss_extra[b] / fights, 1, 1) + " raid members turned Vampire";
}
if(b == 5) {
    s = "Melee brawl: spread out, peel her Charges";
    if(fights > 0) s += ":  " + string_format(global.boss_extra[b] / fights, 1, 1) + " Charges a fight,  " + string_format(global.boss_extra2[b] / fights, 1, 1) + " Intimidating Shouts";
}
if(b == 2) {
    s = "Adds fight";
    if(fights > 0) s += ":  " + string_format(global.boss_extra[b] / fights, 1, 1) + " broodlings killed a fight, of " + string_format(global.boss_extra2[b] / fights, 1, 1) + " hatched";
}
draw_text(x1 + 12, y1 + 28, s);
row = y1 + 50;

for(col = 0; col < 2; col += 1) {
    yy = row + col * (8 * 16 + 14);
    draw_set_color(c_ltgray);
    if(col == 0) draw_text(x1 + 12, yy, "Damage per unit per second (all targets)");
    else draw_text(x1 + 12, yy, "Healing per unit per second");
    top = 1;
    for(i = 0; i < 8; i += 1) if(i != class_mirrorimage) top = max(top, match_boss_rate(b, i, col));
    for(i = 0; i < 8; i += 1) used[i] = (i == class_mirrorimage);
    for(j = 0; j < 7; j += 1) {
        best = -1;
        for(i = 0; i < 8; i += 1) {
            if(used[i]) continue;
            if(best == -1) best = i;
            else if(match_boss_rate(b, i, col) > match_boss_rate(b, best, col)) best = i;
        }
        used[best] = true;
        v = match_boss_rate(b, best, col);
        draw_set_color(c_white);
        draw_text(x1 + 20, yy + 18 + j * 16, job_get_name(best, -1));
        if(v >= 0) {
            draw_set_alpha(.6);
            if(col == 0) draw_set_color(c_orange); else draw_set_color(c_lime);
            draw_rectangle(x1 + 110, yy + 21 + j * 16, x1 + 110 + 300 * v / top, yy + 30 + j * 16, false);
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_text(x1 + 420, yy + 18 + j * 16, string_format(v, 1, 1) + "   (" + string(round(global.boss_cls_secs[b * 8 + best])) + " unit-s)");
        }
        else draw_text(x1 + 420, yy + 18 + j * 16, "no data yet");
    }
}
draw_set_halign(fa_left);
draw_set_color(c_white);
