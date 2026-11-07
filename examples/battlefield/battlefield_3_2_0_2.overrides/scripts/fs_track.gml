// fs_track();
// Called every step by obj_battlefield (gm-revive overrides). Notices when a boss fight starts (a boss
// on the field) and ends, and when it ends, puts up the post-fight summary (obj_fight_summary): won if
// the boss died, wiped if nobody was left standing against it. A boss that's simply cleared away (a
// reset) ends the fight with no summary.
////////////////////////////////////////////////////////////////////////////////////////////
var b, alive, bf;
if(!variable_global_exists("fs_active")) { global.fs_active = false; global.fs_boss = -1; }
b = -1;
with(obj_boss) if(!dead && b == -1) b = id;
if(!global.fs_active) {
    if(b == -1) exit;
    fs_reset();
    global.fs_active = true;
    global.fs_boss = b;
    global.fs_boss_name = raid_boss_display_name(b._bossid);
    if(b.object_index == obj_boss_elmdor) global.fs_boss_name = "Count Vaelric";
    if(b.object_index == obj_boss_zio) global.fs_boss_name = "Dark Prophet Zio";
    global.fs_start = 0;
    with(obj_unit) if(!dead && _bossid == -1 && _jobclass >= 0 && _jobclass != class_mirrorimage) global.fs_start += 1;
    global.fs_boss_pct = 100;
    exit;
}
if(!instance_exists(global.fs_boss)) { global.fs_active = false; exit; }   // cleared away: no summary
if(!global.toggle_pause && !global.cutscene_active) global.fs_steps += 1;
global.fs_boss_pct = max(0, ceil(100 * global.fs_boss._health / max(1, global.fs_boss._maxhealth)));
bf = global.fs_boss._faction;
alive = 0;
with(obj_unit) if(!dead && _bossid == -1 && _jobclass >= 0 && _jobclass != class_mirrorimage && _faction != bf) alive += 1;
if(global.fs_boss.dead || alive == 0) {
    global.fs_won = global.fs_boss.dead;
    global.fs_alive = alive;
    with(obj_boss_lichcaller) { fs_note_set("Lichcaller casts interrupted", _kicks + _setbacks); fs_note_set("Dark Mendings that got through", _mends_landed); }
    with(obj_boss_marquis) { fs_note_set("Units turned vampire", _vamps); fs_note_set("Blows caught by Shirahadori", _caught); }
    with(obj_boss_ladyjane) { fs_note_set("Lady Jane's charges", _charges); fs_note_set("Lady Jane's shouts", _shouts); }
    with(obj_boss_broodmother) { fs_note_set("Broodlings hatched", _broodlings_hatched); fs_note_set("Broodlings killed", _broodlings_killed); }
    with(obj_boss_blighted) fs_note_set("Disease bursts", _bursts);
    global.fs_active = false;
    with(obj_fight_summary) instance_destroy();
    instance_create(0, 0, obj_fight_summary);
}
