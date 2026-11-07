// fs_death(unit);
// A unit died during a boss fight: counted, by class, for the post-fight summary. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
if(!variable_global_exists("fs_active")) exit;
if(!global.fs_active) exit;
if(!instance_exists(argument0)) exit;
var th; th = false;
with(argument0) if(variable_local_exists("_thrall_timer")) { if(_thrall_timer > 0) th = true; }
if(th) exit;   // a thrall dying again
if(argument0._bossid != -1 || argument0._jobclass < 0 || argument0._jobclass == class_mirrorimage) exit;
global.fs_deaths += 1;
ds_list_add(global.fs_died, argument0._jobclass);
