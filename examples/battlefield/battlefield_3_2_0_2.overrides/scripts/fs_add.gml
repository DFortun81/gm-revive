// fs_add(map, unit, amount);
// Adds to one unit's total in one of the post-fight summary's maps (global.fs_dmg / fs_heal / fs_taken)
// while a boss fight is on, and remembers what to call the unit. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var u, k;
if(!variable_global_exists("fs_active")) exit;
if(!global.fs_active || argument2 <= 0) exit;
u = argument1;
if(!instance_exists(u)) exit;
k = u.id;
if(!ds_map_exists(global.fs_label, k)) {
    // numbered within its class for this fight: "Rogue 3" (not "#": that's a line break in draw_text)
    global.fs_classno[max(0, u._jobclass)] += 1;
    ds_map_add(global.fs_label, k, unit_get_name(u) + " " + string(global.fs_classno[max(0, u._jobclass)]));
    ds_map_add(global.fs_class, k, u._jobclass);
}
if(ds_map_exists(argument0, k)) ds_map_replace(argument0, k, ds_map_find_value(argument0, k) + argument2);
else ds_map_add(argument0, k, argument2);
