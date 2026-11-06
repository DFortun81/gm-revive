// match_draw_boss(center_x);
// Page 2 of the results panel: how the raids have done against Stitchgut, and each class's damage
// and healing per unit per second in those fights (single-target numbers: no crowd control, no
// stealth openers, no switching targets).
////////////////////////////////////////////////////////////////////////////////////////////
var cx, w, h, x1, y1, row, i, j, best, used, v, top, s, kills, wipes, col;
cx = argument0;
w = 600; h = 22 + 16 * 22;
x1 = cx - w / 2; y1 = view_yview[0] + view_hview[0] / 2 - h / 2;
draw_set_alpha(.8);
draw_set_color(c_black);
draw_rectangle(x1, y1, x1 + w, y1 + h, false);
draw_window_skinned(x1, y1, x1 + w, y1 + h);
draw_set_alpha(1);
draw_set_halign(fa_left);
kills = global.match_fmt_a[5];
wipes = global.match_fmt_h[5];
s = "Stitchgut: " + string(kills) + " kills, " + string(wipes) + " wipes";
if(kills > 0) s += ",  best kill " + string(round(global.boss_best)) + "s,  average " + string(round(global.boss_time / kills)) + "s";
if(global.match_over && global.match_format == 5) {
    if(global.match_winner == "Alliance") s = "Defeated!   " + s; else s = "Wiped!   " + s;
}
draw_set_color(c_white);
draw_text(x1 + 12, y1 + 10, s + "      [5] close");
row = y1 + 32;

for(col = 0; col < 2; col += 1) {
    draw_set_color(c_ltgray);
    if(col == 0) draw_text(x1 + 12, row, "Damage per unit per second");
    else draw_text(x1 + 12, row + 8 * 16 + 14, "Healing per unit per second");
    // largest value for the bar scale
    top = 1;
    for(i = 0; i < 8; i += 1) {
        if(i == class_mirrorimage || global.boss_cls_secs[i] <= 0) continue;
        if(col == 0) v = global.boss_cls_dmg[i] / global.boss_cls_secs[i]; else v = global.boss_cls_heal[i] / global.boss_cls_secs[i];
        top = max(top, v);
    }
    for(i = 0; i < 8; i += 1) used[i] = (i == class_mirrorimage);
    for(j = 0; j < 7; j += 1) {
        best = -1;
        for(i = 0; i < 8; i += 1) {
            if(used[i]) continue;
            if(best == -1) best = i;
            else if(match_boss_rate(i, col) > match_boss_rate(best, col)) best = i;
        }
        used[best] = true;
        v = match_boss_rate(best, col);
        draw_set_color(c_white);
        draw_text(x1 + 20, row + 18 + j * 16 + col * (8 * 16 + 14), job_get_name(best, -1));
        if(global.boss_cls_secs[best] > 0) {
            draw_set_alpha(.6);
            if(col == 0) draw_set_color(c_orange); else draw_set_color(c_lime);
            draw_rectangle(x1 + 110, row + 21 + j * 16 + col * (8 * 16 + 14), x1 + 110 + 300 * v / top, row + 30 + j * 16 + col * (8 * 16 + 14), false);
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_text(x1 + 420, row + 18 + j * 16 + col * (8 * 16 + 14), string_format(v, 1, 1) + "   (" + string(round(global.boss_cls_secs[best])) + " unit-s)");
        }
        else draw_text(x1 + 420, row + 18 + j * 16 + col * (8 * 16 + 14), "no data yet");
    }
}
draw_set_halign(fa_left);
draw_set_color(c_white);
