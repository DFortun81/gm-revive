if(global.raid_boss == id) global.raid_boss = -1;
ds_list_destroy(_arealist);
event_inherited();
