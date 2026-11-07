// Stitchgut: the tank-and-spank training boss (gm-revive overrides). The shared raid boss parts are in
// obj_boss_raid; this adds Hateful Strike. Measures sustained single-target damage, healing, tanking.
// (gm-revive overrides, Nov 2026) Two more for a fuller kit: Gut Hook drags a unit at the back into his
// reach, and Bile Spew drenches everyone in a cone in front of him in acid.
event_inherited();

_health_per_enemy = 5000;
_swing_damage = 110;
_swing_speed = room_speed * 1.5;

// Hateful Strike: the healthiest unit in melee range other than the target (the target if alone)
_hateful_damage = 120;
_hateful_cooldown_time = room_speed * 2.5;
_hateful_cooldown = _hateful_cooldown_time;

// Gut Hook: hurls a hook on a chain at a unit standing back from him (healers and casters first) and
// reels it in to his feet, stunned for a moment
_hook_damage = 40;
_hook_cooldown_time = room_speed * 15;
_hook_cooldown = room_speed * 8;
_hook_min_range = 110;

// Bile Spew: a gout of acid in a cone in front of him (toward his tank)
_spew_damage = 55;
_spew_range = 110;
_spew_angle = 40;              // either side of where he faces
_spew_cooldown_time = room_speed * 12;
_spew_cooldown = room_speed * 5;
_hooks = 0;
