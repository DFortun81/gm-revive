// The Blighted: the healing check (gm-revive overrides; a raid boss, see obj_boss_raid).
// A slow, rotting brute whose danger is attrition: Blight Aura hits the whole raid every 2 seconds and
// grows the longer the fight lasts, and Festering Blight diseases a random raid member. A diseased unit
// that dies bursts, infecting everyone near it. Measures how much healing a raid can keep up.
// (gm-revive overrides, Nov 2026) Miasma: he also breathes out a lingering cloud of rot where the raid
// is thickest; it eats at everyone standing in it for 6 s.
event_inherited();
image_xscale = 1.7;
image_yscale = 1.7;

_health_per_enemy = 6000;
_swing_damage = 70;
_swing_speed = room_speed * 2;
_normal_movespeed = 0.7;
_movespeed = _normal_movespeed;

// Blight Aura: every 2 s, _aura_base damage to every enemy, plus 1 for every _aura_ramp of fight
_aura_time = room_speed * 2;
_aura_timer = _aura_time;
_aura_base = 6;
_aura_ramp = room_speed * 6;
_aura_range = 1000;            // the whole field

// Festering Blight: a 15 s disease, 15 damage a second; bursts on death onto units within 64 px
_blight_time = room_speed * 6;
_blight_timer = room_speed * 4;
_blight_duration = room_speed * 15;
_blight_tick = 15;
_blight_burst_range = 64;
_blight_burst_damage = 30;

// Miasma: a 6 s cloud (radius 55) where the raid is thickest, 10 damage every half second inside it
_miasma_time = room_speed * 16;
_miasma_timer = room_speed * 9;
_miasma_radius = 55;
_miasma_tick = 10;

// For the results
_clouds = 0;
_bursts = 0;
_peak_aura = 0;
with(obj_unit) _blight_timer_on = 0;
