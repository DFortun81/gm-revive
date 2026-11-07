// An icy shard pointing the way it flies, inside a pale blue glow with a white centre
var hh;
hh = y - _h;
draw_set_color(c_black);
draw_set_alpha(0.2);
draw_ellipse(x - 4, y - 2, x + 4, y + 2, false);
draw_set_alpha(1);
draw_set_color(c_white);
if(_web > 0) {
    // a glob of web
    draw_sprite_ext(sprite_index, 0, x, hh, 0.3, 0.3, 0, make_color_rgb(235, 235, 225), 1);
}
else if(_shadow) {
    // a Shadow Bolt: a ball of violet-black with a pale core
    draw_sprite_ext(sprite_index, 0, x, hh, 0.7, 0.7, 0, make_color_rgb(40, 0, 60), 0.85);
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(sprite_index, 0, x, hh, 0.45, 0.45, 0, make_color_rgb(160, 70, 255), 1);
    draw_sprite_ext(sprite_index, 0, x, hh, 0.2, 0.2, 0, make_color_rgb(235, 210, 255), 1);
    draw_set_blend_mode(bm_normal);
}
else {
    draw_sprite_ext(sprite_index, 0, x, hh, 0.6, 0.6, 0, make_color_rgb(70, 150, 255), 0.8);
    draw_sprite_ext(sprite_index, 6, x, hh, 0.55, 0.55, image_angle - 90, make_color_rgb(150, 215, 255), 1);
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(sprite_index, 0, x, hh, 0.3, 0.3, 0, make_color_rgb(200, 235, 255), 1);
    draw_set_blend_mode(bm_normal);
}
