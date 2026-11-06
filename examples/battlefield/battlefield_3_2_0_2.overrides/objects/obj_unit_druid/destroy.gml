// Undo anything this Druid still has running, then the original cleanup
druid_release();
ds_list_destroy(_healerlist);
event_inherited();
