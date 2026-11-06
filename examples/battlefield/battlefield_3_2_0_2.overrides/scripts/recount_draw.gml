// recount_draw();
// Draws the Recount-style meter at the top of the screen when global.recount_mode is on
// (key 4 cycles: off, damage done, healing done, damage taken). One bar per faction and class.
////////////////////////////////////////////////////////////////////////////////////////////
var lists, title, pq, j, f, l, v, total, best, rows, n, key, x1, y1, w, rh, bw, fname, col, i;
if(global.recount_mode <= 0) exit;
switch(global.recount_mode) {
    case 1: lists = global._recount_damage_done; title = "Damage Done"; break;
    case 2: lists = global._recount_healing_done; title = "Healing Done"; break;
    default: lists = global._recount_damage_taken; title = "Damage Taken"; break;
}

// Sort every non-zero faction/class total, largest first
pq = ds_priority_create();
total = 0;
for(j = 0; j < ds_list_size(lists); j += 1) {
    if(j == class_mirrorimage) continue;
    l = ds_list_find_value(lists, j);
    for(f = 0; f < ds_list_size(l); f += 1) {
        v = ds_list_find_value(l, f);
        if(v > 0) {
            ds_priority_add(pq, j * 100 + f, v);
            total += v;
        }
    }
}

rows = min(10, ds_priority_size(pq));
w = 260; rh = 16;
x1 = view_xview[0] + view_wview[0] / 2 - w / 2;
y1 = view_yview[0] + 20; // below the match label
if(instance_exists(obj_boss)) y1 = view_yview[0] + 74; // ...and below the boss health window
draw_set_alpha(.5);
draw_set_color(c_black);
draw_window_skinned(x1, y1, x1 + w, y1 + 30 + max(1, rows) * rh);
draw_set_alpha(1);
draw_set_font(fnt_normal);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_text(x1 + 10, y1 + 6, title);
draw_set_halign(fa_right);
draw_text(x1 + w - 10, y1 + 6, "Total " + string(round(total)) + "   [4]");

if(rows == 0) {
    draw_set_halign(fa_left);
    draw_text(x1 + 10, y1 + 24, "Nothing yet");
}
best = ds_priority_find_priority(pq, ds_priority_find_max(pq));
for(i = 0; i < rows; i += 1) {
    key = ds_priority_find_max(pq);
    v = ds_priority_find_priority(pq, key);
    ds_priority_delete_max(pq);
    j = key div 100;
    f = key mod 100;
    fname = ds_list_find_value(global.faction_names, f);
    col = faction_get_color(fname);
    bw = (w - 20) * (v / best);
    draw_set_alpha(.6);
    draw_set_color(col);
    draw_rectangle(x1 + 10, y1 + 24 + i * rh, x1 + 10 + bw, y1 + 24 + i * rh + rh - 2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_text(x1 + 14, y1 + 24 + i * rh, string(i + 1) + ". " + fname + " " + job_get_name(j, -1));
    draw_set_halign(fa_right);
    draw_text(x1 + w - 14, y1 + 24 + i * rh, string(round(v)) + " (" + string(round(v / total * 100)) + "%)");
}
ds_priority_destroy(pq);
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);
