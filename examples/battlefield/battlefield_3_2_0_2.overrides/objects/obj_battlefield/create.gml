selected = -1;
gameover = false;
_gameover = false;
gameover_alpha = 0;

instance_create(0, 0, obj_sky);

sprite_replace_png("muramasa", spr_muramasa_ghost, 3);
sprite_set_alpha_from_sprite(spr_circle_alpha, spr_circle_alpha);
sprite_set_alpha_from_sprite(spr_thunderclap, spr_circle_alpha);
sprite_set_alpha_from_sprite(spr_muramasa, spr_circle_alpha2);

sprite_set_alpha_from_sprite(spr_totem_area_red, spr_circle_alpha);
sprite_set_alpha_from_sprite(spr_totem_area_green, spr_circle_alpha);
sprite_set_alpha_from_sprite(spr_totem_area_blue, spr_circle_alpha);
sprite_set_alpha_from_sprite(spr_totem_area_white, spr_circle_alpha);

// Viewing variables
if(!variable_global_exists("toggle_targets")) global.toggle_targets = false;
if(!variable_global_exists("toggle_reach")) global.toggle_reach = false;
if(!variable_global_exists("toggle_numbers")) global.toggle_numbers = true;
if(!variable_global_exists("toggle_pause")) global.toggle_pause = true;
if(!variable_global_exists("calc_healing")) global.calc_healing = 0;
if(!variable_global_exists("calc_damage")) global.calc_damage = 0;

global.faction_names = ds_list_create();
global.faction_colors = ds_list_create();
global.faction_units = ds_list_create();
global.faction_agents = ds_list_create();

global.job_name = ds_list_create();
global.job_object = ds_list_create();

global.boss_name = ds_list_create();
global.boss_object = ds_list_create();
global.boss_intro = ds_list_create();
global.boss_main = ds_list_create();
global.boss_sprite = ds_list_create();

global.text_effect_x = ds_list_create();
global.text_effect_y = ds_list_create();
global.text_effect_alpha = ds_list_create();
global.text_effect_color = ds_list_create();
global.text_effect_difference = ds_list_create();
global.text_effect_variance = ds_list_create();
global.text_effect_string = ds_list_create();

global._global_text = ds_list_create();

global.cutscene = false;
global.cutscene_active = false;
global.cutscene_focus = -1;
global._totemEffectToggle = false;

global._recount_damage_done = ds_list_create();
global._recount_damage_taken = ds_list_create();
global._recount_healing_done = ds_list_create();
global._recount_healing_taken = ds_list_create();

//sound_global_volume(100);
sound_loop(snd_battle);
sound_replace_mp3("snd_boss_zio_intro", snd_ziointro);
sound_replace_mp3("snd_boss_zio_battle2", snd_zioboss);
sound_replace_mp3("snd_boss_elmdor_battle", snd_elmdor_main);

job_create("Warrior", obj_unit_warrior);
job_create("Caster", obj_unit_caster);
job_create("Healer", obj_unit_healer);
job_create("Mirror Image", obj_mirror_image);
job_create("Shaman", obj_unit_shaman);
job_create("Rogue", obj_unit_rogue);
job_create("Druid", obj_unit_druid);
job_create("Paladin", obj_unit_paladin);

faction_create("Horde", c_red);
faction_set_unit_sprite("Horde", class_warrior, spr_red_warrior);
faction_set_unit_sprite("Horde", class_caster, spr_red_caster);
faction_set_unit_sprite("Horde", class_healer, spr_red_healer);
faction_set_unit_sprite("Horde", class_mirrorimage, spr_red_caster);
faction_set_unit_sprite("Horde", class_shaman, spr_red_shaman);
faction_set_unit_sprite("Horde", class_rogue, spr_red_rogue);
faction_set_unit_sprite("Horde", class_druid, spr_red_druid);
faction_set_unit_sprite("Horde", class_paladin, spr_red_paladin);

faction_create("Alliance", c_blue);
faction_set_unit_sprite("Alliance", class_warrior, spr_blue_warrior);
faction_set_unit_sprite("Alliance", class_caster, spr_blue_caster);
faction_set_unit_sprite("Alliance", class_healer, spr_blue_healer);
faction_set_unit_sprite("Alliance", class_mirrorimage, spr_blue_caster);
faction_set_unit_sprite("Alliance", class_shaman, spr_blue_shaman);
faction_set_unit_sprite("Alliance", class_rogue, spr_blue_rogue);
faction_set_unit_sprite("Alliance", class_druid, spr_blue_druid);
faction_set_unit_sprite("Alliance", class_paladin, spr_blue_paladin);

boss_create("Zio", obj_boss_zio, snd_ziointro, snd_zioboss);
boss_create("Elmdor", obj_boss_elmdor, snd_elmdor_main, snd_elmdor_main);
// (gm-revive overrides) the raid bosses (key 8 spawns them in turn): Stitchgut the tank-and-spank,
// Lichcaller the interrupt check, Broodmother the adds fight, The Blighted the healing check
global.boss_stitchgut = ds_list_size(global.boss_name);
boss_create("Stitchgut", obj_boss_stitchgut, snd_zioboss, snd_zioboss);
global.boss_lichcaller = ds_list_size(global.boss_name);
boss_create("Lichcaller", obj_boss_lichcaller, snd_zioboss, snd_zioboss);
global.boss_broodmother = ds_list_size(global.boss_name);
boss_create("Broodmother", obj_boss_broodmother, snd_zioboss, snd_zioboss);
global.raid_boss_ids[0] = global.boss_stitchgut;
global.raid_boss_ids[1] = global.boss_lichcaller;
global.raid_boss_ids[2] = global.boss_broodmother;
global.boss_blighted = ds_list_size(global.boss_name);
boss_create("Blighted", obj_boss_blighted, snd_zioboss, snd_zioboss);
global.raid_boss_ids[3] = global.boss_blighted;
// The faction each one spawns as; the game shows it in front of the name ("Dark Prophet Zio")
global.raid_boss_titles[0] = "Abomination";
global.raid_boss_titles[1] = "Undying";
global.raid_boss_titles[2] = "Hive";
global.raid_boss_titles[3] = "The"; // shown as "The Blighted"
// Names for the match label, results and messages
global.raid_boss_display[0] = "Stitchgut";
global.raid_boss_display[1] = "Lichcaller";
global.raid_boss_display[2] = "Broodmother";
global.raid_boss_display[3] = "The Blighted";
if(!variable_global_exists("raid_boss_next")) global.raid_boss_next = 0;

// (gm-revive overrides) The armies now come from match_setup: each reset picks one of several
// formats (the original army, or 3v3 / 5v5 / 10v10 / 20v20 of random classes) and keeps a record
// of who won. The original army is in match_spawn_classic.
match_setup();
