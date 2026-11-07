var t, f, s, a;
t = _life / _maxlife;
// Colours are drawn normally (additive light would turn every flame yellow on the bright grass);
// only the white-hot centres are added on top.
if(_kind == 1) {
    // Smoke: grows and fades, darkening what's behind it
    s = _size * (0.6 + t * 1.2);
    draw_sprite_ext(sprite_index, 4, x, y - _h, s, s, 0, c_white, 0.35 * (1 - t));
}
else if(_kind == 0) {
    f = min(3, _hot + floor(t * (4 - _hot)));
    s = _size * (1 - t * 0.55);
    draw_sprite_ext(sprite_index, f, x, y - _h, s, s, 0, c_white, 0.9 * (1 - t * t));
    if(t < 0.35) {
        draw_set_blend_mode(bm_add);
        draw_sprite_ext(sprite_index, 0, x, y - _h, s * 0.55, s * 0.55, 0, c_white, 0.6 * (1 - t / 0.35));
        draw_set_blend_mode(bm_normal);
    }
}
else if(_kind == 2) {
    draw_sprite_ext(sprite_index, 2, x, y - _h, _size * 0.9, _size * 0.9, 0, c_white, 1 - t);
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(sprite_index, 5, x, y - _h, _size, _size, 0, c_white, 1 - t);
    draw_set_blend_mode(bm_normal);
}
else {
    // Impact: an orange bloom with a white-hot heart and an expanding ring of heat
    s = _size * (0.7 + t * 1.5);
    draw_sprite_ext(sprite_index, 3, x, y - _h, s * 1.2, s * 1.2, 0, c_white, 0.7 * (1 - t));
    draw_sprite_ext(sprite_index, 2, x, y - _h, s, s, 0, c_white, 1 - t);
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(sprite_index, 0, x, y - _h, s * 0.6, s * 0.6, 0, c_white, (1 - t) * (1 - t));
    draw_set_blend_mode(bm_normal);
    draw_set_alpha((1 - t) * 0.9);
    draw_set_color(make_color_rgb(255, 120, 30));
    draw_circle(x, y - _h * 0.4, 4 + t * 18, true);
    draw_set_color(make_color_rgb(255, 200, 90));
    draw_circle(x, y - _h * 0.4, 3 + t * 17, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
