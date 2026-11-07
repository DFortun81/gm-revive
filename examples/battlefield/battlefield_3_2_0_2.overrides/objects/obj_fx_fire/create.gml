// A single fire particle (gm-revive overrides): flames and smoke for the Fireball's trail, embers
// and the flash ring for its impact. Each frame of spr_fx_fire is pre-coloured, so nothing is tinted
// at draw time and a 40-Caster battle stays quick to draw.
// _kind: 0 flame (cools white -> yellow -> orange -> red as it ages), 1 smoke, 2 ember, 3 impact flash
_kind = 0;
_life = 0;
_maxlife = 14;
_h = 0;             // height above the ground
_vx = 0; _vy = 0;   // drift on the ground plane
_vh = 0;            // rise (flames, smoke) or fall (embers)
_size = 0.4;
_hot = 0;           // flames: the frame they start at (0 white-hot ... 3 red)
image_speed = 0;
