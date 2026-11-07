// A bat (gm-revive overrides; sprite 088-Monster02 from the RPG Maker XP sets): bursts out of Count
// Vaelric when a Blood Suck ends and when he Mist Steps, flaps away and fades. Set _ang after creating it.
_ang = random(360);
_spd = random_range(1.6, 2.8);
_life = 0;
_maxlife = 36 + irandom(14);
_h = random_range(12, 30);
_vh = random_range(0.3, 0.9);
_flap = irandom(3);
image_speed = 0;
