var a;
a = image_alpha * min(1, (_timer - _t) / 8);
draw_sprite_ext(sprite_index, image_index, x, y - _height, 1, 1, image_angle, c_white, a);
// a pale additive copy so it reads as a gust of wind on the grass, not a dark smudge
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y - _height, 1.05, 1.05, image_angle, make_color_rgb(150, 180, 220), a * 0.9);
draw_set_blend_mode(bm_normal);
