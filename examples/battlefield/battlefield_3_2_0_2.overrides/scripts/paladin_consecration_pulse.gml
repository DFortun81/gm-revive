// paladin_consecration_pulse(x, y, range);
// One pulse of Consecration (gm-revive overrides): a ring of golden light rolls across the consecrated
// ground over a turning holy sigil. (Was a flat glowing disc.)
/////////////////////////////////////////////////////////////////////////////////////////////////////
var p;
with(fx_make(1, argument0, argument1, 0, make_color_rgb(200, 140, 30), argument2 / 11, 30)) { _squash = 0.45; _add = false; _alpha = 0.6; }
with(fx_make(1, argument0, argument1, 0, make_color_rgb(255, 225, 120), argument2 / 14, 24)) { _squash = 0.45; _alpha = 0.8; }
p = fx_make(10, argument0, argument1, 0, make_color_rgb(255, 210, 90), argument2 / 15, 30); p._squash = 0.45; p._spin = 2; p.image_angle = random(360); p._dz = -40;
