// fs_reset();
// Starts the post-fight summary's bookkeeping for a new boss fight (gm-revive overrides): per-unit
// damage, healing and damage taken, deaths, and notable events (fs_note). See fs_track.
////////////////////////////////////////////////////////////////////////////////////////////
if(!variable_global_exists("fs_dmg")) {
    global.fs_dmg = ds_map_create();
    global.fs_heal = ds_map_create();
    global.fs_taken = ds_map_create();
    global.fs_label = ds_map_create();
    global.fs_class = ds_map_create();
    global.fs_notes = ds_map_create();
    global.fs_note_order = ds_list_create();
    global.fs_died = ds_list_create();
}
ds_map_clear(global.fs_dmg);
ds_map_clear(global.fs_heal);
ds_map_clear(global.fs_taken);
ds_map_clear(global.fs_label);
ds_map_clear(global.fs_class);
ds_map_clear(global.fs_notes);
ds_list_clear(global.fs_note_order);
ds_list_clear(global.fs_died);
global.fs_steps = 0;
var j; for(j = 0; j < 16; j += 1) global.fs_classno[j] = 0;
global.fs_deaths = 0;
