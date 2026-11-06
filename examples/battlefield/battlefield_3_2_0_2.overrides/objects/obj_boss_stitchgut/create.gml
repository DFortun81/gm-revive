// Stitchgut: the tank-and-spank training boss (gm-revive overrides). The shared raid boss parts are in
// obj_boss_raid; this adds Hateful Strike. Measures sustained single-target damage, healing, tanking.
event_inherited();

_health_per_enemy = 5000;
_swing_damage = 110;
_swing_speed = room_speed * 1.5;

// Hateful Strike: the healthiest unit in melee range other than the target (the target if alone)
_hateful_damage = 120;
_hateful_cooldown_time = room_speed * 2.5;
_hateful_cooldown = _hateful_cooldown_time;
