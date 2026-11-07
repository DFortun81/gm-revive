// Celia and Lede, Marquis Elmdor's Assassins (gm-revive overrides; a new child of obj_unit, so every
// class's AI fights them). Spawned by obj_boss_marquis when the fight starts, with its faction.
//  * Melee, preferring healers and casters; a target below 12% health is cut down outright.
//  * Shadow Stitch: a ranged Stop (a 2.5 s stun) on a raid member, healers first.
//  * Ultima (1.5 s cast, can be interrupted): magic damage to everyone near the target.
// Killed once, each rises again as an Ultima Demon: no more Stop or instant kills, but Ultima comes
// faster and hits harder.
event_inherited();
_jobclass = -1;
_bossid = -1;
_master = -1;
_name = "Celia";
_maxhealth = 2000;
_health = _maxhealth;
_manatype = -1;
_normal_movespeed = 1.3;
_movespeed = _normal_movespeed;
_animate = true;
_blendcolor = c_white;
_attackdamage = 18;
_attackspeed = room_speed;
_attackcooldown = room_speed div 2;
_attackrange = range_melee;
_target = -1;

_reborn = false;               // true once it has risen as an Ultima Demon
_stitch_cooldown_time = room_speed * 15;
_stitch_cooldown = room_speed * 5;
_stitch_duration = room_speed * 2.5;
_death_cooldown_time = room_speed * 20;
_death_cooldown = room_speed * 6;
_ultima_cooldown_time = room_speed * 15;
_ultima_cooldown = room_speed * 10;
_ultima_casttime = room_speed * 1.5;
_ultima_damage = 50;
_ultima_radius = 60;
_ultima_target = -1;
_casting = false;
