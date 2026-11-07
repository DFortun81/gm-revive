// Dark Force (gm-revive overrides: the game's own draw event, plus the mark on the unit Supreme Black
// Wave will hit: a dark tether from the face to it that strengthens as the cast bar fills, and a
// shadowy ring at its feet)
var hover, d, barsize, k, fx, fy, tx, ty, i, n, px, py, qx, qy, a;
hover = _ydif - _height; d = degtorad(45);
if(_casting && units_exists(_target)) {
    k = _attackcastwait / max(1, _attackcasttime);
    fx = x; fy = y + hover - 26;
    tx = _target.x; ty = _target.y - _target.sprite_height * 0.5;
    a = (0.45 + 0.55 * k) * (0.8 + 0.2 * sin(current_time / 90));
    n = 10; px = fx; py = fy;
    for(i = 1; i <= n; i += 1) {
        qx = fx + (tx - fx) * i / n + random_range(-3, 3) * (i < n);
        qy = fy + (ty - fy) * i / n + random_range(-3, 3) * (i < n);
        draw_set_alpha(a * 0.6);
        draw_set_color(make_color_rgb(40, 0, 60));
        draw_line_width(px, py, qx, qy, 6);
        draw_set_alpha(a);
        draw_set_color(make_color_rgb(190, 90, 255));
        draw_line_width(px, py, qx, qy, 2);
        px = qx; py = qy;
    }
    draw_set_alpha(1);
    draw_sprite_ext(spr_fx_misc, 3, _target.x, _target.y, 1.3 + 0.15 * sin(current_time / 150), 0.62 + 0.07 * sin(current_time / 150), 0, make_color_rgb(110, 40, 170), 0.55 + 0.45 * k);
    draw_sprite_ext(spr_fx_misc, 0, tx, ty, 0.6 + 0.7 * k, 0.6 + 0.7 * k, 0, make_color_rgb(70, 0, 110), 0.3 + 0.4 * k);
    draw_set_color(c_white);
}
draw_sprite_ext(sprite_index, image_index, x - cos(d) * hover, y + sin(d) * hover, 1, 1, -45, c_black, image_alpha / 10);
draw_sprite_ext(sprite_index, image_index, x, y + hover, 1, 1, 0, c_white, image_alpha);

barsize = 20;
if(_attackcastwait > 0) {
    draw_set_alpha(.5);
    draw_set_color(c_black);
    draw_healthbar(x - barsize, y - 4 - sprite_yoffset - _height, x + barsize, y - sprite_yoffset - _height, (_attackcastwait / _attackcasttime) * 100, c_white, c_blue, c_blue, 0, false, false);
    draw_rectangle(x - barsize, y - 4 - sprite_yoffset - _height, x + barsize, y - sprite_yoffset - _height, true);
    draw_set_alpha(1);
}
