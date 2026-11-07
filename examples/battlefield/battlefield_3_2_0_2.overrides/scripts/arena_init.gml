// arena_init();
// The eight boss encounters for the boss select screen and their arenas (gm-revive overrides). Index:
// 0-5 the raid bosses in global.raid_boss_ids order (Stitchgut, Lichcaller, Broodmother, The Blighted,
// Marquis Elmdor, Lady Jane), 6 Zio, 7 Count Vaelric. Each arena is an 800x600 backdrop built from the
// RPG Maker XP tilesets in Graphics\RPG\Tilesets (see the README).
////////////////////////////////////////////////////////////////////////////////////////////
var k, sec;
if(variable_global_exists("arena_spr")) exit;
global.arena_obj[0] = obj_boss_stitchgut;   global.arena_spr[0] = spr_arena_sewer;      global.arena_name[0] = "the sewers";
global.arena_obj[1] = obj_boss_lichcaller;  global.arena_spr[1] = spr_arena_ice;        global.arena_name[1] = "the ice temple";
global.arena_obj[2] = obj_boss_broodmother; global.arena_spr[2] = spr_arena_nest;       global.arena_name[2] = "the brood cave";
global.arena_obj[3] = obj_boss_blighted;    global.arena_spr[3] = spr_arena_ruins;      global.arena_name[3] = "the blighted ruins";
global.arena_obj[4] = obj_boss_marquis;     global.arena_spr[4] = spr_arena_castle;     global.arena_name[4] = "Limberry Castle";
global.arena_obj[5] = obj_boss_ladyjane;    global.arena_spr[5] = spr_arena_church;     global.arena_name[5] = "the church";
global.arena_obj[6] = obj_boss_zio;         global.arena_spr[6] = spr_arena_space;      global.arena_name[6] = "the void";
global.arena_obj[7] = obj_boss_elmdor;      global.arena_spr[7] = spr_arena_evilcastle; global.arena_name[7] = "Castle Vaelric";
for(k = 0; k < 6; k += 1) global.arena_title[k] = global.raid_boss_display[k];
global.arena_title[6] = "Dark Prophet Zio";
global.arena_title[7] = "Count Vaelric";
global.arena_cur = -1;
if(!variable_global_exists("select_boss")) global.select_boss = -1;
// best kills (any fight against the boss, whether picked here or spawned by hand), kept with the match results
ini_open("battlefield_matches.ini");
for(k = 0; k < 8; k += 1) global.arena_best[k] = ini_read_real("bestkill", string(k), 0);
ini_close();
