// sound_level_apply();
// Sets the game's volume from global.sound_level (gm-revive overrides): 2 full, 1 quiet, 0 muted.
// Key M cycles it, and it's kept in battlefield_settings.ini (apart from the match results, so
// clearing those with 7 doesn't touch it).
////////////////////////////////////////////////////////////////////////////////////////////
if(global.sound_level >= 2) sound_global_volume(1);
else if(global.sound_level == 1) sound_global_volume(0.35);
else sound_global_volume(0);
