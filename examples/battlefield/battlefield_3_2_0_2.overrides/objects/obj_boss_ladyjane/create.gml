// Lady Jane: the duelist with a great axe (gm-revive overrides; a raid boss, see obj_boss_raid), from the
// Call to Arms version of the game (sprite, battle music and her opening lines from cta_0_2_4.gmk). There
// she was a Warrior; here the Warrior's kit becomes boss mechanics:
//  * Heroic Strike: a heavy extra blow on her tank. Rend: a bleed on her tank.
//  * Thunder Clap: hits everyone close to her.
//  * Charge: breaks off to rush a raid member at range (healers and casters first), stunning them;
//    the tank has to hold her as she walks back.
//  * Intimidating Shout: everyone near her is frozen with fear for a moment.
//  * Execute: finishes off a target under 20% health.
//  * Bloodrage: bursts of extra damage. Last Stand: once, near death, she heals and toughens up.
// The first fight in a session opens with her exchange with the raid; she can't be interrupted or stunned.
event_inherited();
image_xscale = 1.35;
image_yscale = 1.35;
_health_per_enemy = 3200;
_swing_damage = 85;
_swing_speed = room_speed * 1.6;
_normal_movespeed = 1.1;
_movespeed = _normal_movespeed;

_heroic_damage = 110;
_heroic_cooldown_time = room_speed * 7;
_heroic_cooldown = room_speed * 4;

_rend_tick = 7;               // a second, for _rend_duration
_rend_duration = room_speed * 9;
_rend_target = -1;
_rend_timer = 0;

_clap_damage = 35;
_clap_range = 75;
_clap_cooldown_time = room_speed * 10;
_clap_cooldown = room_speed * 6;

_charge_damage = 45;
_charge_stun = room_speed * 1;
_charge_min_range = 120;
_charge_cooldown_time = room_speed * 16;
_charge_cooldown = room_speed * 8;
_charge_x = 0; _charge_y = 0; _charging = 0; _charge_target = -1;

_shout_range = 95;
_shout_fear = room_speed * 2;
_shout_cooldown_time = room_speed * 24;
_shout_cooldown = room_speed * 14;

_execute_damage = 180;
_execute_cooldown_time = room_speed * 8;
_execute_cooldown = 0;

_bloodrage_cooldown_time = room_speed * 30;
_bloodrage_cooldown = room_speed * 20;
_bloodrage_timer = 0;
_dmg_mult = 1;

_laststand_used = false;
_laststand_timer = 0;

_intro = 0;                    // her opening exchange (first fight in a session)
_intro_timer = 0;
_intro_t = -1;
_message_timer = 0;

// For the results
_charges = 0;
_shouts = 0;

sound_stop_all();
sound_loop(snd_ladyjane_battle);
