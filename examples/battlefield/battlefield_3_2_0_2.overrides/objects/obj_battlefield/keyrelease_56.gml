// (gm-revive overrides) Key 8: spawn Stitchgut, the tank-and-spank training boss, at the mouse
if(instance_exists(obj_boss_stitchgut)) exit;
spawn_boss(mouse_x, mouse_y, global.boss_stitchgut, "Abomination");
