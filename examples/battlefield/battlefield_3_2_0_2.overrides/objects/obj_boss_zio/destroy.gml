// (gm-revive overrides) The game's own destroy event, and the Horde's totems go back to their side (the
// units do so themselves in obj_unit's begin step once he's gone)
global.cutscene = false;
global.cutscene_intro = false;
global.cutscene_focus = -1;
sound_play(snd_victory);
with(obj_totem) if(variable_local_exists("_zio_faction")) { if(_zio_faction != "") { _faction = _zio_faction; _zio_faction = ""; } }
