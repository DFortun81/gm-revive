// match_setup();
// Called when the battlefield starts (and on every reset): picks a format and spawns the armies.
// Formats: 0 the original army, 5 a random 15-unit raid against a raid boss (Stitchgut,
// Lichcaller, Broodmother or The Blighted), 1-4 a 3v3 / 5v5 / 10v10 / 20v20 where every unit on each side is a
// random class, in mirrored formations (Alliance on the left, Horde on the right).
////////////////////////////////////////////////////////////////////////////////////////////
var f, n, k, c, cols, rows, col, row, dx, yy, side_a, side_h;
if(!variable_global_exists("match_count")) match_load();
if(!variable_global_exists("match_auto")) global.match_auto = true;
if(!variable_global_exists("match_show")) global.match_show = false;

f = irandom(5);
if(f == global.match_format) f = irandom(5); // a repeat is less likely
global.match_format = f;
switch(f) {
    case 1: n = 3; break;
    case 2: n = 5; break;
    case 3: n = 10; break;
    case 4: n = 20; break;
    case 5: n = 15; break; // Boss: a random 15-unit raid against one of the raid bosses
    default: n = 0; break;
}
global.match_boss = irandom(3); // which raid boss, if this is a Boss match
global.match_over = false;
global.match_end_timer = 0;
global.match_steps = 0;
global.match_winner = "";
for(c = 0; c < 8; c += 1) {
    global.match_comp_a[c] = 0;
    global.match_comp_h[c] = 0;
}

if(f == 0) {
    match_spawn_classic();
    exit;
}

// Roll each side's classes, then line both sides up in mirrored formations facing each other across
// the middle of the field: front-line classes in the ranks nearest the enemy, Casters and Healers
// behind. Slot k on the Alliance side is the mirror image of slot k on the Horde side, so neither
// side has further to walk.
side_a = ds_list_create();
side_h = ds_list_create();
for(k = 0; k < n; k += 1) {
    c = choose(class_warrior, class_caster, class_healer, class_shaman, class_rogue, class_druid, class_paladin);
    ds_list_add(side_a, c);
    global.match_comp_a[c] += 1;
    if(f != 5) {
        c = choose(class_warrior, class_caster, class_healer, class_shaman, class_rogue, class_druid, class_paladin);
        ds_list_add(side_h, c);
        global.match_comp_h[c] += 1;
    }
}
match_formation_sort(side_a);
match_formation_sort(side_h);
cols = ceil(n / 5);
rows = ceil(n / cols);
for(k = 0; k < n; k += 1) {
    col = k div rows;            // 0 = front rank
    row = k mod rows;
    dx = 100 + col * 40;         // front ranks start 200 px apart, ranks 40 px deep
    yy = room_height / 2 + (row - (rows - 1) / 2) * 48;
    create_unit(room_width / 2 - dx, yy, ds_list_find_value(side_a, k), "Alliance");
    if(f != 5) create_unit(room_width / 2 + dx, yy, ds_list_find_value(side_h, k), "Horde");
}
if(f == 5) spawn_boss(room_width / 2 + 100, room_height / 2, global.raid_boss_ids[global.match_boss], global.raid_boss_titles[global.match_boss]);
ds_list_destroy(side_a);
ds_list_destroy(side_h);
