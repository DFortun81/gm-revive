// recount_reset();
// Clears the damage meter (every job's damage done / taken and healing done / taken).
////////////////////////////////////////////////////////////////////////////////////////////
var j;
for(j = 0; j < ds_list_size(global._recount_damage_done); j += 1) {
    ds_list_clear(ds_list_find_value(global._recount_damage_done, j));
    ds_list_clear(ds_list_find_value(global._recount_damage_taken, j));
    ds_list_clear(ds_list_find_value(global._recount_healing_done, j));
    ds_list_clear(ds_list_find_value(global._recount_healing_taken, j));
}
