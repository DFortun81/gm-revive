// An effect that stays on a unit while something lasts (gm-revive overrides), drawn from spr_fx_misc.
// _kind: 0 stunned (circling stars), 1 Divine Shield / Blessing of Protection (a golden bubble),
// 2 Evasion (afterimages), 3 Evocation (a rune circle with motes spiralling in), 4 Shadow Word: Pain,
// 5 Masamune (Regen and Haste on Marquis Elmdor), 6 Vampire, 7 the Magic Barrier on Zio (lives as long as he does), 8 Black Wave curse, 9 drained by
// Count Vaelric's Blood Suck, 10 his thrall
_master = -1;
_kind = 0;
_t = 0;
_ending = -1;
_src = -1;
_last_absorb = 0; // Magic Barrier: what it held last step, to spot hits and the moment it breaks
_hit = 0;         // Magic Barrier: flashes the outline when it absorbs a hit     // Shadow Word: Pain: the Healer whose dot this is  // counts down while the effect fades out
image_speed = 0;
