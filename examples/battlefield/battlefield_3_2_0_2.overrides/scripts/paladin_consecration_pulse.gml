// paladin_consecration_pulse(x, y, range);
// One half-second tick of Consecration (gm-revive overrides): a ring of golden light spreads across the
// consecrated ground and fades at its edge. (The sigil is obj_fx_consecration, which lasts the whole
// spell; this used to be a flat glowing disc, and briefly a fresh sigil every tick.)
/////////////////////////////////////////////////////////////////////////////////////////////////////
with(fx_make(1, argument0, argument1, 0, make_color_rgb(255, 225, 120), argument2 / 16, 26)) { _squash = 0.45; _alpha = 0.6; _dz = -40; }
