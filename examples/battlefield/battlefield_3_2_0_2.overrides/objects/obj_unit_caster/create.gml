/* Call default Unit Create Method */
event_inherited();

_maxhealth = 120;
_health = _maxhealth;

_manatype_maxmana = 450;
_manatype_mana = _manatype_maxmana;
_manatype = manatype_mana;
// (gm-revive overrides) A trickle of mana regeneration, so a Caster who has run dry can still throw a
// Fireball every couple of seconds instead of standing idle until Evocation comes back.
_mana_regen = 1.5; // mana per second (a Fireball costs 3 and normally goes out every 0.6 s)
// Mana Gem: an instant mana potion on a cooldown. Used once the Caster drops to 40% mana, so it
// comes before Evocation (which waits for 20%). Usable while casting, but not while stunned or sheeped.
_managem_cooldown = 0;
_managem_cooldown_time = room_speed * 60;
_managem_amount = 0.35;    // fraction of maximum mana restored (about 157 of 450)
_managem_threshold = 0.4;  // used at or below this fraction of maximum mana

_normal_movespeed = 1;
_movespeed = _normal_movespeed; // This value changes

// Default (ranged) attack: Fireball.
_attackrange = range_cast;
_attackdamage = 56;
_normal_attackcasttime = room_speed * .6;
_attackcasttime = _normal_attackcasttime;
_fireball_manacost = 3;
_fireball_casttime = _attackcasttime;

// Casters get a special ability called Evocation that they can cast once they reach below 20% mana
// If will give that caster 60% of its maximum mana over the duration period.
_evocation_cooldown = 0;
_evocation_cooldown_time = room_speed * 120;
_evocation_casting = false;
_evocation_castduration = room_speed * 10;

// Casters get another special ability called Polymorph that can turn an enemy unit into a sheep for 6 seconds
// Any damage to this target by any means will break the CC, 6 second cooldown.
_polymorph_cooldown = 0;
_polymorph_cooldown_time = room_speed * 6; // <-- Equivalent to 6 seconds under perfect conditions
_polymorph_casting = false;
_polymorph_casttime = room_speed; // <-- Equivalent to 1 second under perfect conditions
_polymorph_manacost = 1;

// Caster Special Ability: Blink
// Teleports the Caster to a safer area approximately their casting range away from their current position
// Also Creates a Mirror Image in place of itself that will take enemy damage and casting effects as if it was its own
_blink_cooldown = 0;
_blink_cooldown_time = room_speed * 15; // <-- 15 seconds under perfect conditions
_blink_manacost = 1;

// Caster Special Ability: Mirror Images
// Creates 3 Mirror Images around the caster that do a small amount of damage and have low health (approx. 1/3 the amount of the Caster)
// Can be cast once every minute, Mirror Images fade away after 30 seconds
_mirrorimage_cooldown = 0;
_mirrorimage_cooldown_time = room_speed * 60;
_mirrorimage_manacost = 3;

// Caster Special Ability: Blizzard
// Creates a small-scale Blizzard centered around the target's original location. Engulfs any enemy units within 64 feet of the target.
_blizzard_cooldown = 0;
_blizzard_cooldown_time = room_speed * 10;
_blizzard_casting = false;
_blizzard_casttime = room_speed * 10;
_blizzard_amount = 6;
_blizzard_manacost = 1; // Per damage application
_blizzard_x = -1;
_blizzard_y = -1;

// Caster Special Ability: Fire Blast
// Instantly damages the target with the power of fire
_fireblast_cooldown = 0;
_fireblast_cooldown_time = room_speed * 9;
_fireblast_amount = 23;
_fireblast_manacost = 1;

// Caster Special Ability: Mana Shield
// The mage uses his own Mana reserves to put up a temporary absorb shield on himself.
_manashield_cooldown = 0;
_manashield_cooldown_time = room_speed * 3;
_manashield_amount = 100;
_manashield_manacost = 0.75; // Per point of health

// ---- Added by gm-revive overrides: state for Polymorph, Blink and Blizzard ----
_polymorph_duration = room_speed * 6;    // how long the sheep lasts
_polymorph_victim = -1;                  // one sheep at a time per Caster
_polymorph_range = range_heal;           // reaches healers standing at healing range
_blink_distance = range_cast * 0.8;      // roughly casting range away
_blizzard_radius = range_cast / 2;       // matches the obj_blizzard pulse ring
_blizzard_tick_time = 10;                // damage every 10 steps
_blizzard_tick = 0;
_blizzard_min_targets = 3;               // only worth channelling on a group

// (gm-revive overrides) Wand: see unit_fallback
_wand_cooldown = 0;
_wand_cooldown_time = room_speed * 1.5;
