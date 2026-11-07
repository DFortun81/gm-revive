// a cold haze over the storm
draw_sprite_ext(spr_fx_misc, 0, x, y, _r / 13, _r / 26, 0, make_color_rgb(120, 180, 230), 0.35);
draw_set_blend_mode(bm_add);
draw_sprite_ext(spr_fx_misc, 0, x, y, _r / 18, _r / 36, 0, make_color_rgb(60, 100, 140), 0.4);
draw_set_blend_mode(bm_normal);
