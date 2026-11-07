// Broodmother: the adds fight (gm-revive overrides; a raid boss, see obj_boss_raid).
// A melee boss that keeps calling in waves of broodlings from around the edges of the field. They are
// weak alone but come in numbers from every side and go for the healers and casters at the back, so the raid needs area damage (Blizzard, Chain
// Lightning, Consecration, Swipe, Thunder Clap) and tanks that pick them up.
event_inherited();
_health_per_enemy = 3000;
_swing_damage = 90;
_swing_speed = room_speed * 1.5;

_brood_cooldown_time = room_speed * 8;
// (gm-revive overrides, Nov 2026) Web Wrap: she spits a strand of web at a raid member at the back
// (healers and casters first) and wraps it in a cocoon for 5 s
_web_cooldown_time = room_speed * 14;
_web_cooldown = room_speed * 6;
_web_duration = room_speed * 5;
_webs = 0;
_brood_cooldown = room_speed * 4;
_brood_base = 3;          // broodlings per wave: this many, plus one for every 5 units in the raid

_message_timer = 0;

// For the results
_broodlings_hatched = 0;
_broodlings_killed = 0;
