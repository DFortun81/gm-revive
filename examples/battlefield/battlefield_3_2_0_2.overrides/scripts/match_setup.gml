// match_setup();
// Called when the battlefield starts (and on every reset): picks a format and spawns the armies.
// Formats: 0 the original army, 1-4 a 3v3 / 5v5 / 10v10 / 20v20 where every unit on each side is a
// random class, Alliance starting on the left and Horde on the right.
////////////////////////////////////////////////////////////////////////////////////////////
var f, n, k, c, fac, x1, x2, margin;
if(!variable_global_exists("match_count")) match_load();
if(!variable_global_exists("match_auto")) global.match_auto = true;
if(!variable_global_exists("match_show")) global.match_show = false;

f = irandom(4);
if(f == global.match_format) f = irandom(4); // a repeat is less likely
global.match_format = f;
switch(f) {
    case 1: n = 3; break;
    case 2: n = 5; break;
    case 3: n = 10; break;
    case 4: n = 20; break;
    default: n = 0; break;
}
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

margin = 80; // keep clear of the unit panels down both sides of the screen
for(k = 0; k < n * 2; k += 1) {
    c = choose(class_warrior, class_caster, class_healer, class_shaman, class_rogue, class_druid, class_paladin);
    if(k < n) {
        fac = "Alliance";
        x1 = margin; x2 = room_width * 0.3;
        global.match_comp_a[c] += 1;
    }
    else {
        fac = "Horde";
        x1 = room_width * 0.7; x2 = room_width - margin;
        global.match_comp_h[c] += 1;
    }
    create_unit(random_range(x1, x2), random_range(40, room_height - 40), c, fac);
}
