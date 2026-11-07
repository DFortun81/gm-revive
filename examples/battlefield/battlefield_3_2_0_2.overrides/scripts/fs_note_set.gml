// fs_note_set(name, count);
// Sets a notable count for the post-fight summary outright (a boss's own tally). (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
if(argument1 <= 0) exit;
if(!ds_map_exists(global.fs_notes, argument0)) { ds_map_add(global.fs_notes, argument0, argument1); ds_list_add(global.fs_note_order, argument0); }
else ds_map_replace(global.fs_notes, argument0, argument1);
