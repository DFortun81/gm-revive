// Broodmother: the adds fight (gm-revive overrides; a raid boss, see obj_boss_raid).
// A melee boss that keeps hatching waves of broodlings. They are weak alone but come in numbers and
// go for the healers and casters at the back, so the raid needs area damage (Blizzard, Chain
// Lightning, Consecration, Swipe, Thunder Clap) and tanks that pick them up.
event_inherited();
_health_per_enemy = 3000;
_swing_damage = 90;
_swing_speed = room_speed * 1.5;

_brood_cooldown_time = room_speed * 8;
_brood_cooldown = room_speed * 4;
_brood_base = 3;          // broodlings per wave: this many, plus one for every 5 units in the raid

// For the results
_broodlings_hatched = 0;
_broodlings_killed = 0;
