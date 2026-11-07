// boss_sfx(sound);
// A boss ability's sound effect (gm-revive overrides). Only bosses get sound effects, so a big fight
// stays readable; and a sound that is still playing isn't started again, so an ability that hits many
// units at once (Festering Blight, Shadow Stitch) or a quick string of casts doesn't pile up into noise.
// The sounds are from the RPG Maker sound effect set, levelled to about the same loudness.
////////////////////////////////////////////////////////////////////////////////////////////
if(sound_isplaying(argument0)) exit;
sound_play(argument0);
