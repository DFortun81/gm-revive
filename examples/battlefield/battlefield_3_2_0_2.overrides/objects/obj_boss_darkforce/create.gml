// Dark Force (gm-revive overrides: the game's own create event, with the 30 s Supreme Black Wave from the
// Call to Arms version of the fight, and the hovering face sprite from that version, spr_darkforce_face)
_ydif = 0;
_ydir = 0;
_master = -1;
_powerup = true;
_casting = false;
_savedtarget = -1;
image_alpha = 0.06;

// Dark Force Special Ability: Black Wave
// Instantly damages a random enemy unit with the power of death
_blackwave_cooldown = 0;
_blackwave_cooldown_time = 0;
_blackwave_amount = 2600;
_blackwave_casttime = room_speed * 30; // (gm-revive overrides) 30 s, as in Call to Arms (was 10) // <-- Equivalent to 30 seconds under perfect conditions

_attackcasttime = _blackwave_casttime;
_attackcastwait = 0;
_height = 64;