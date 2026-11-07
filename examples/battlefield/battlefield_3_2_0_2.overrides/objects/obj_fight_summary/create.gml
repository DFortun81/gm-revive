// The post-fight summary (gm-revive overrides): put up by fs_track when a boss fight ends, won or
// wiped. Everything is copied out of the fight's bookkeeping into strings here, so it stays right
// even after the field resets (it's persistent, so a match's automatic restart doesn't take it away).
// It appears 1.5 s after the fight ends, and goes on a click, or after 25 s.
var pq, k, i, n, secs, j, cnt, s, c, best, bv;
_delay = room_speed * 1.5;
_life = room_speed * 25;
_t = 0;
secs = global.fs_steps / room_speed;
if(global.fs_won) _title = "Victory!  " + global.fs_boss_name + " defeated";
else _title = "Wiped.  " + global.fs_boss_name + " survived at " + string(global.fs_boss_pct) + "%";
s = string(floor(secs / 60)) + ":" + string_replace(string_format(floor(secs) mod 60, 2, 0), " ", "0");
_line = "Fight time " + s + "    Raid " + string(global.fs_start) + " -> " + string(global.fs_alive) + " standing    " + string(global.fs_deaths) + " deaths";
// top lists: _dmg_n / _dmg_s[i], _heal_*, _taken_*
for(j = 0; j < 3; j += 1) {
    if(j == 0) { pq = global.fs_dmg; n = 5; }
    if(j == 1) { pq = global.fs_heal; n = 5; }
    if(j == 2) { pq = global.fs_taken; n = 3; }
    c = ds_priority_create();
    k = ds_map_find_first(pq);
    for(i = 0; i < ds_map_size(pq); i += 1) { ds_priority_add(c, k, ds_map_find_value(pq, k)); k = ds_map_find_next(pq, k); }
    cnt = 0;
    while(cnt < n && ds_priority_size(c) > 0) {
        bv = ds_priority_find_priority(c, ds_priority_find_max(c));
        best = ds_priority_delete_max(c);
        s = string(cnt + 1) + ". " + ds_map_find_value(global.fs_label, best) + "  " + string(round(bv));
        if(j < 2 && secs > 0) s += "  (" + string(round(bv / secs)) + "/s)";
        if(j == 0) _dmg_s[cnt] = s;
        if(j == 1) _heal_s[cnt] = s;
        if(j == 2) _taken_s[cnt] = s;
        cnt += 1;
    }
    if(j == 0) _dmg_n = cnt;
    if(j == 1) _heal_n = cnt;
    if(j == 2) _taken_n = cnt;
    ds_priority_destroy(c);
}
// deaths by class
_deaths = "";
for(j = 0; j < 8; j += 1) {
    cnt = 0;
    for(i = 0; i < ds_list_size(global.fs_died); i += 1) if(ds_list_find_value(global.fs_died, i) == j) cnt += 1;
    if(cnt > 0) { if(_deaths != "") _deaths += ",  "; _deaths += job_get_name(j, -1) + " " + string(cnt); }
}
if(_deaths == "") _deaths = "nobody";
// notable events
_notes_n = 0;
for(i = 0; i < ds_list_size(global.fs_note_order); i += 1) {
    k = ds_list_find_value(global.fs_note_order, i);
    _notes_s[_notes_n] = k + ": " + string(ds_map_find_value(global.fs_notes, k));
    _notes_n += 1;
}
