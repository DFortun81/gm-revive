// Lichcaller: the interrupt check (gm-revive overrides; a raid boss, see obj_boss_raid).
// Keeps its distance and Shadow Bolts whoever has threat. Every so often it casts Dark Mending (a big
// heal on itself) or Shadow Volley (damage to the whole raid). Both can be stopped: Rogue Kick cancels
// the cast and locks it out for a moment, the Shaman's Wind Shear totem knocks the cast bar back to
// the start. A raid that can't do either faces a fight that heals itself and wears them down.
event_inherited();
_interuptimmune = false;      // Dark Mending and Shadow Volley can be interrupted (Shadow Bolt can't)

_health_per_enemy = 4000;
_melee = false;
_keep_range = range_cast * 0.6;

// Shadow Bolt: its normal attack on the threat target
_bolt_damage = 85;
_bolt_casttime = room_speed * 1.2;
_bolt_cooldown_time = room_speed * 0.4;
_bolt_cooldown = room_speed;

// Dark Mending: heals itself for 10% of its health
_mend_fraction = 0.1;
_mend_casttime = room_speed * 3;
_mend_cooldown_time = room_speed * 14;
_mend_cooldown = room_speed * 8;

// Shadow Volley: hits every enemy unit
_volley_damage = 70;
_volley_casttime = room_speed * 2.5;
_volley_cooldown_time = room_speed * 18;
_volley_cooldown = room_speed * 12;

_retry_time = room_speed * 5;  // an interrupted spell comes back this much sooner than its cooldown
_cast = 0;                     // 0 nothing, 1 Shadow Bolt, 2 Dark Mending, 3 Shadow Volley
_last_wait = 0;

// For the results: what the raid stopped, and what got through
_kicks = 0;
_setbacks = 0;
_mends_landed = 0;
_volleys_landed = 0;
