// raid_boss_display_name(boss_id);
// The name a raid boss goes by in messages ("The Blighted"), or the boss list's name for any other boss.
////////////////////////////////////////////////////////////////////////////////////////////
var k;
for(k = 0; k < 4; k += 1) {
    if(global.raid_boss_ids[k] == argument0) return global.raid_boss_display[k];
}
return boss_get_name(argument0);
