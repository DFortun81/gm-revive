// (gm-revive overrides) B: the boss select screen
if(instance_exists(obj_boss_select)) with(obj_boss_select) instance_destroy();
else instance_create(0, 0, obj_boss_select);
