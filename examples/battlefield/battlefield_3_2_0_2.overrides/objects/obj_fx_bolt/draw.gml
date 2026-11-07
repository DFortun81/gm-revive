var i, a, k;
if(_life < 1) exit;
a = 1 - _life / _maxlife;
// outer smoke, purple body, pale core
for(k = 0; k < 3; k += 1) {
    if(k == 0) { draw_set_color(_c0); draw_set_alpha(0.75 * a); }
    if(k == 1) { draw_set_color(_c1); draw_set_alpha(0.9 * a); }
    if(k == 2) { draw_set_blend_mode(bm_add); draw_set_color(_c2); draw_set_alpha(a); }
    for(i = 1; i <= _n; i += 1) draw_line_width(_px[i - 1], _py[i - 1], _px[i], _py[i], _w * (7 - k * 2.6));
    draw_line_width(_px[_bi], _py[_bi], _bx, _by, _w * (4 - k * 1.4));
}
draw_set_blend_mode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
// glows where it leaves and where it lands
draw_sprite_ext(sprite_index, 0, _px[_n], _py[_n], 0.7 * _w, 0.7 * _w, 0, _c0, 0.6 * a);
draw_set_blend_mode(bm_add);
draw_sprite_ext(sprite_index, 0, _px[_n], _py[_n], 0.45 * _w, 0.45 * _w, 0, _c1, a);
draw_sprite_ext(sprite_index, 0, _px[0], _py[0], 0.3 * _w, 0.3 * _w, 0, _c1, a * 0.8);
draw_set_blend_mode(bm_normal);
