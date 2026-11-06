// Stitchgut: a tank-and-spank training boss (gm-revive overrides; a new object, child of obj_boss).
// No cutscenes and no tricks: it hits whoever has the most threat, Hateful Strikes the healthiest
// other unit in melee, and enrages after 3 minutes. Used to measure sustained damage, healing and
// tanking (see the Boss format and tools/balance_sim.js boss mode).
event_inherited();

// obj_boss starts an intro cutscene; this boss has none
global.cutscene = false;
global.cutscene_active = false;
global.cutscene_focus = -1;
_canbepolymorphed = false;
_interuptimmune = true;

_blendcolor = c_white; // its own sprite now (052-Undead02 from the RPG sprite collection)

// Health is set when the fight starts: _health_per_enemy for every unit in the raid, so a bigger
// raid doesn't mean a shorter fight
_health_per_enemy = 5000;
_maxhealth = _health_per_enemy;
_health = _maxhealth;
_manatype = -1;

_normal_movespeed = 1;
_movespeed = _normal_movespeed;
_animate = true;

// Melee swing on the current target (the tank)
_swing_damage = 110;
_swing_speed = room_speed * 1.5;
_swing_cooldown = room_speed;

// Hateful Strike: the healthiest unit in melee range other than the target (the target if alone)
_hateful_damage = 120;
_hateful_cooldown_time = room_speed * 2.5;
_hateful_cooldown = _hateful_cooldown_time;

// Enrage: double damage and faster swings once the fight has gone on too long
_enrage_time = room_speed * 180;
_enraged = false;

_fight_started = false;
_fight_steps = 0;
_threat_switch = 1.1; // someone has to pass the current target's threat by 10% to pull

// Everyone starts with no threat on this boss (one Stitchgut at a time)
with(obj_unit) _stitch_threat = 0;
global.stitchgut = id;

sound_stop_all();
sound_play(snd_startbattle);
sound_loop(snd_zioboss);
