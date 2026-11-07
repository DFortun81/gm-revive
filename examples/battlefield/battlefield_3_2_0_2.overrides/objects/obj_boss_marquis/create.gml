// Marquis Elmdor: the duel (gm-revive overrides; a raid boss, see obj_boss_raid), after the Limberry
// Castle fight in Final Fantasy Tactics. A katana master with two Assassins at his side.
//  * Shirahadori: catches a good share of melee blows outright; spells always land (he has no magic
//    evasion), so casters carry this fight.
//  * Teleport + Chirijiraden: blinks behind a raid member who isn't tanking him (anywhere on the
//    field) and cuts them, then walks back to his tank.
//  * Kikuichimonji: an instant sweep through everyone in a cone in front of him. Don't stack up on him.
//  * Vampire: his bite turns a raid member into a vampire who fights for him for a while; its melee
//    hits can spread it. Healers are never turned (vampires attack, they don't heal), and a vampire
//    only hits its old side at half strength. It wears off, or when the vampire is beaten down to a
//    quarter of its health.
//  * Masamune (cast): Regen and Haste on himself.
//  * Muramasa (cast): ghosts of the sword strike everyone in casting range.
//  * He can't be interrupted or stunned: his casts always go off.
//  * Celia and Lede (obj_marquis_assassin) fight beside him; each rises once as an Ultima Demon.
event_inherited();
_health_per_enemy = 2600;
_swing_damage = 90;
_swing_speed = room_speed * 1.4;
_normal_movespeed = 1.1;
_movespeed = _normal_movespeed;
_interuptimmune = true;        // nothing interrupts him (Kick, Wind Shear); like every boss, stuns don't land either

_shirahadori_chance = 0.3;

_chiri_damage = 80;            // a Caster at full health survives it
_chiri_cooldown_time = room_speed * 18;
_chiri_cooldown = room_speed * 6;

_kiku_damage = 80;
_kiku_range = 95;
_kiku_arc = 40;                // half-width of the cone, in degrees
_kiku_cooldown_time = room_speed * 9;
_kiku_cooldown = room_speed * 5;

_vamp_duration = room_speed * 10;
_vamp_max = 2;                 // vampires at once
_vamp_spread = 0.05;           // chance a vampire's melee hit turns its victim too
_vamp_cooldown_time = room_speed * 20;
_vamp_cooldown = room_speed * 9;

_masamune_casttime = room_speed * 1.2;
_masamune_cooldown_time = room_speed * 32;
_masamune_cooldown = room_speed * 14;
_regen_fraction = 0.004;       // of his health, every second, for 10 s
_regen_timer = 0;
_haste_timer = 0;

_muramasa_casttime = room_speed * 2;
_muramasa_damage = 65;
_muramasa_cooldown_time = room_speed * 30;
_muramasa_cooldown = room_speed * 20;
_muramasa_casting = false;     // obj_muramasa (the ghost swords) watches this

_retry_time = room_speed * 6;  // an interrupted spell comes back this much sooner than its cooldown
_cast = 0;                     // 0 nothing, 1 Masamune, 2 Muramasa
_assassins_up = false;
_last_caught = 0;
_message_timer = 0;

// For the results
_caught = 0;                   // blows caught by Shirahadori
_vamps = 0;                    // raid members turned
_kicks = 0;

sound_stop_all();
sound_play(snd_startbattle);
sound_loop(snd_elmdor_main);
