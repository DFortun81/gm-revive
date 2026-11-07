// fs_note(name);
// Counts one notable event for the post-fight summary ("Interrupts", "Blood Suck broken"...), while a
// boss fight is on. They're listed in the order they first happened. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
if(!variable_global_exists("fs_active")) exit;
if(!global.fs_active) exit;
if(ds_map_exists(global.fs_notes, argument0)) ds_map_replace(global.fs_notes, argument0, ds_map_find_value(global.fs_notes, argument0) + 1);
else { ds_map_add(global.fs_notes, argument0, 1); ds_list_add(global.fs_note_order, argument0); }
