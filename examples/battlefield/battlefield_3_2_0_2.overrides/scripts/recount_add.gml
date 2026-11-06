// recount_add(recount_list, jobclass, faction_name, amount);
// Adds to one of the global._recount_* lists. Each of those holds one list per job (made by
// job_create), indexed by the faction's position in global.faction_names.
////////////////////////////////////////////////////////////////////////////////////////////
var l, f;
if(argument1 < 0 || argument1 >= ds_list_size(argument0) || argument3 <= 0) exit;
f = ds_list_find_index(global.faction_names, argument2);
if(f < 0) exit;
l = ds_list_find_value(argument0, argument1);
while(ds_list_size(l) <= f) ds_list_add(l, 0);
ds_list_replace(l, f, ds_list_find_value(l, f) + argument3);
