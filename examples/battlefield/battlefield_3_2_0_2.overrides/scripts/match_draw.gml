// match_draw();
// Draws the match label at the top of the screen, the winner banner between matches, and the
// results panel (key 5).
////////////////////////////////////////////////////////////////////////////////////////////
var cx, cy, s, secs, col, i, j, best, order, used, w, h, x1, y1, row, pct, n, f, yy;
if(!variable_global_exists("match_count")) exit;
cx = view_xview[0] + view_wview[0] / 2;
draw_set_font(fnt_normal);
draw_set_alpha(1);

// Label
secs = floor(global.match_steps / room_speed);
s = "Match " + string(global.match_count + !global.match_over) + "  -  " + match_format_name(global.match_format);
if(global.match_format == 5) s += ": " + global.raid_boss_display[global.match_boss];
s += "  -  " + string(secs div 60) + ":";
if(secs mod 60 < 10) s += "0";
s += string(secs mod 60) + "      [5] results   [6] auto-reset ";
if(global.match_auto) s += "on"; else s += "off";
// Below the game's own boss window while a boss is out, and below the bosses' dialogue boxes while
// they're talking (the boss window is 12 + 32 px a boss tall, each dialogue box 36 px; see obj_sky)
yy = view_yview[0] + 2;
if(instance_exists(obj_boss)) {
    n = instance_number(obj_boss);
    yy = view_yview[0] + 12 + n * 32 + 6;
    if(global.cutscene_active) {
        f = false;
        with(obj_boss) if(_message != "") f = true;
        if(f) yy += n * 36 + 4;
    }
}
draw_set_halign(fa_center);
draw_set_color(c_black);
draw_text(cx + 1, yy + 1, s);
draw_set_color(c_white);
draw_text(cx, yy, s);

// Winner banner (the results panel shows it instead while it's open)
if(global.match_over && !global.match_show) {
    cy = view_yview[0] + view_hview[0] / 2 - 40;
    if(global.match_format == 5) {
        if(global.match_winner == "Alliance") { s = string_upper(global.raid_boss_display[global.match_boss]) + " DEFEATED!"; col = c_lime; }
        else { s = "RAID WIPED"; col = c_red; }
    }
    else if(global.match_winner == "") { s = "DRAW"; col = c_white; }
    else { s = string_upper(global.match_winner) + " WINS!"; col = faction_get_color(global.match_winner); }
    draw_set_font(fnt_victory);
    draw_set_color(c_black);
    draw_text(cx + 2, cy + 2, s);
    draw_set_color(merge_color(col, c_white, 0.35));
    draw_text(cx, cy, s);
    draw_set_font(fnt_normal);
    draw_set_color(c_white);
    if(global.match_auto) s = "Next match in " + string(ceil(max(0, global.match_end_timer) / room_speed));
    else s = "Auto-reset is off: [6] turns it on, F1 starts a new match";
    draw_text(cx, cy + 56, s);
}

// Results panel, page 1: matches (key 5; pressing it again shows page 2, the boss)
if(global.match_show == 1) {
    w = 600; h = 22 + 16 * (2 + 7 + 1 + 5 + 1 + 2 * min(5, global.match_recent_n)) + 10;
    x1 = cx - w / 2; y1 = view_yview[0] + view_hview[0] / 2 - h / 2;
    draw_set_alpha(.8);
    draw_set_color(c_black);
    draw_rectangle(x1, y1, x1 + w, y1 + h, false);
    draw_window_skinned(x1, y1, x1 + w, y1 + h);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    row = y1 + 10;
    s = "Results: " + string(global.match_count) + " matches (saved in this browser)    [5] boss pages   [7] twice: clear";
    if(global.match_over) {
        if(global.match_winner == "") s = "Draw!   " + s; else s = global.match_winner + " wins!   " + s;
    }
    draw_text(x1 + 12, row, s);
    row += 22;
    draw_set_color(c_ltgray);
    draw_text(x1 + 12, row, "Class win rate in random-class matches (share of its units that ended on the winning side)");
    row += 18;

    // Classes sorted by win rate
    for(i = 0; i < 8; i += 1) used[i] = (i == class_mirrorimage);
    for(j = 0; j < 7; j += 1) {
        best = -1;
        for(i = 0; i < 8; i += 1) {
            if(used[i]) continue;
            if(best == -1) best = i;
            else if(global.match_cls_wins[i] / max(1, global.match_cls_units[i]) > global.match_cls_wins[best] / max(1, global.match_cls_units[best])) best = i;
        }
        used[best] = true;
        n = global.match_cls_units[best];
        pct = global.match_cls_wins[best] / max(1, n);
        draw_set_color(c_white);
        draw_text(x1 + 20, row, job_get_name(best, -1));
        draw_set_alpha(.6);
        draw_set_color(merge_color(c_red, c_lime, pct));
        if(n > 0) draw_rectangle(x1 + 110, row + 3, x1 + 110 + 240 * pct, row + 12, false);
        draw_set_alpha(1);
        draw_set_color(c_dkgray);
        draw_line(x1 + 230, row + 1, x1 + 230, row + 14); // 50% mark
        draw_set_color(c_white);
        if(n > 0) draw_text(x1 + 360, row, string(round(pct * 100)) + "%   (" + string(n) + " units)");
        else draw_text(x1 + 360, row, "no data yet");
        row += 16;
    }
    row += 6;
    draw_set_color(c_ltgray);
    draw_text(x1 + 12, row, "Formats (Alliance - Horde - draw; Boss: kills - wipes)");
    row += 16;
    draw_set_color(c_white);
    for(f = 0; f < 6; f += 1) {
        s = match_format_name(f) + ":  " + string(global.match_fmt_a[f]) + " - " + string(global.match_fmt_h[f]);
        if(f != 5) s += " - " + string(global.match_fmt_d[f]);
        draw_text(x1 + 20 + (f mod 3) * 190, row + (f div 3) * 16, s);
    }
    row += 40;
    draw_set_color(c_ltgray);
    draw_text(x1 + 12, row, "Recent");
    row += 16;
    for(i = 0; i < min(5, global.match_recent_n); i += 1) {
        draw_set_color(c_white);
        draw_text(x1 + 20, row, global.match_recent[i]);
        draw_set_color(c_ltgray);
        draw_text(x1 + 30, row + 14, global.match_recent2[i]);
        row += 32;
    }
}

// Results panel, pages 2-4: the raid bosses
if(global.match_show >= 2) match_draw_boss(cx, global.match_show - 2);
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
