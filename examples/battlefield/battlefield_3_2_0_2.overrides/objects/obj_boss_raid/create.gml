// obj_boss_raid: the shared parent of the raid bosses (gm-revive overrides; a new object, child of obj_boss).
// What every raid boss has: no cutscenes, health scaled to the raid when the fight starts, a threat
// table (raid_threat), a target it only gives up when someone out-threats it by 10%, an optional
// melee swing, and an enrage. Children set their numbers after event_inherited() and add their own
// abilities in their end step, after event_inherited().
event_inherited();

// obj_boss starts an intro cutscene; raid bosses have none
global.cutscene = false;
global.cutscene_active = false;
global.cutscene_focus = -1;
_canbepolymorphed = false;
_interuptimmune = true;
_blendcolor = c_white;

_health_per_enemy = 5000;     // health for every unit in the raid, set when the fight starts
_maxhealth = _health_per_enemy;
_health = _maxhealth;
_manatype = -1;

_normal_movespeed = 1;
_movespeed = _normal_movespeed;
_animate = true;
_idle_animate = false;         // true: keeps animating while standing still (flying or floating bosses)

_melee = true;                 // false: keeps _keep_range from its target instead of closing in
_keep_range = range_cast * 0.75;
_swing_damage = 110;
_swing_speed = room_speed * 1.5;
_swing_cooldown = room_speed;

_enrage_time = room_speed * 180;
// (gm-revive overrides) Everyone an area attack can hit: the enemy list plus Mirror Images. Bosses never
// target or tank a Mirror Image (they're left off _enemylist), but anything that hits an area hits them.
_arealist = ds_list_create();
_enraged = false;
_enrage_mult = 1;              // 2 once enraged: children multiply their own ability damage by it

_fight_started = false;
_fight_steps = 0;
_threat_switch = 1.1;
_raid_casting = false;         // children set this while casting something Kick / Wind Shear can stop
_raid_cast_interrupted = false; // set by unit_interrupt; the child cancels its cast and clears it

with(obj_unit) _raid_threat = 0;
global.raid_boss = id;

sound_stop_all();
sound_play(snd_startbattle);
sound_loop(snd_zioboss);
