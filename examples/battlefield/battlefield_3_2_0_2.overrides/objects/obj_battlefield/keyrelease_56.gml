// (gm-revive overrides) Key 8: spawn the next raid boss at the mouse (Stitchgut, Lichcaller,
// Broodmother, The Blighted, Marquis Elmdor, Lady Jane, then round again). One raid boss at a time.
if(instance_exists(obj_boss_raid)) exit;
spawn_boss(mouse_x, mouse_y, global.raid_boss_ids[global.raid_boss_next], global.raid_boss_titles[global.raid_boss_next]);
global.raid_boss_next = (global.raid_boss_next + 1) mod global.raid_boss_count;
