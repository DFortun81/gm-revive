// Fireball (gm-revive overrides): a white-hot core inside red, orange and yellow layers that flicker
// a little, over a soft shadow on the ground. The colours are drawn normally so they stay fiery on
// the green grass; only the core is additive.
var hh, fl;
hh = y - _h;
fl = 1 + random_range(-0.1, 0.1);
draw_set_color(c_black);
draw_set_alpha(0.25);
draw_ellipse(x - 5, y - 2, x + 5, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_sprite_ext(spr_fx_fire, 3, x, hh, 0.95 * fl, 0.95 * fl, 0, c_white, 0.75);
draw_sprite_ext(spr_fx_fire, 2, x, hh, 0.7 * fl, 0.7 * fl, 0, c_white, 1);
draw_sprite_ext(spr_fx_fire, 1, x, hh, 0.48 * fl, 0.48 * fl, 0, c_white, 1);
draw_set_blend_mode(bm_add);
draw_sprite_ext(spr_fx_fire, 0, x, hh, 0.34 * fl, 0.34 * fl, 0, c_white, 1);
draw_set_blend_mode(bm_normal);
