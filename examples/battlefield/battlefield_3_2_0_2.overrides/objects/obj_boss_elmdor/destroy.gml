// Count Vaelric (gm-revive overrides): the game's own destroy event, without the victory music (far too loud)
global.cutscene = false;
global.cutscene_intro = false;
global.cutscene_focus = -1;
if(variable_local_exists("_drain_victim")) vaelric_drain_end();
