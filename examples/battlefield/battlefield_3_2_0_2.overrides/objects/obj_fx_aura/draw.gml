var fade, i, a, sx, sy, top, cy, sc, front;
if(!instance_exists(_master)) exit;
if(_master._stealthed) exit;
fade = 1;
if(_ending >= 0) fade = _ending / 10;
fade = min(fade, _t / 6);
switch(_kind) {
    case 0: // three stars circling over the head
        top = _master.y - _master.sprite_height + 3;
        for(i = 0; i < 3; i += 1) {
            a = _t * 7 + i * 120;
            sx = x + lengthdir_x(9, a);
            sy = top + lengthdir_y(9, a) * 0.35;
            front = 0.55 + 0.45 * (lengthdir_y(1, a) > 0);
            draw_set_blend_mode(bm_add);
            draw_sprite_ext(sprite_index, 0, sx, sy, 0.3, 0.3, 0, make_color_rgb(255, 200, 60), 0.5 * fade * front);
            draw_set_blend_mode(bm_normal);
            draw_sprite_ext(sprite_index, 1, sx, sy, 0.32, 0.32, _t * 6, make_color_rgb(255, 225, 60), fade * front);
        }
    break;
    case 1: // golden bubble
        cy = _master.y - _master.sprite_height * 0.45;
        sc = max(_master.sprite_width, _master.sprite_height) / 25 * (1 + 0.04 * sin(_t * 0.15));
        draw_sprite_ext(sprite_index, 0, x, cy, sc * 1.15, sc * 1.15, 0, make_color_rgb(255, 200, 60), 0.3 * fade);
        draw_sprite_ext(sprite_index, 5, x, cy, sc, sc, 0, make_color_rgb(255, 205, 70), fade);
        draw_set_blend_mode(bm_add);
        draw_sprite_ext(sprite_index, 5, x, cy, sc, sc, 0, make_color_rgb(255, 230, 150), 0.45 * fade);
        draw_set_blend_mode(bm_normal);
    break;
    case 2: // Evasion: afterimages drifting either side
        a = 4.5 + sin(_t * 0.25) * 2;
        draw_sprite_ext(_master.sprite_index, _master.image_index, x - a * 1.8, y, 1, 1, 0, c_white, 0.18 * fade);
        draw_sprite_ext(_master.sprite_index, _master.image_index, x + a * 1.8, y, 1, 1, 0, c_white, 0.18 * fade);
        draw_sprite_ext(_master.sprite_index, _master.image_index, x - a, y, 1, 1, 0, c_white, 0.38 * fade);
        draw_sprite_ext(_master.sprite_index, _master.image_index, x + a, y, 1, 1, 0, c_white, 0.38 * fade);
    break;
    case 3: // Evocation: a pulsing rune circle on the ground, with lights running round it
        a = (0.75 + 0.25 * sin(_t * 0.2)) * fade;
        draw_sprite_ext(sprite_index, 3, x, y, 1.2, 0.58, 0, make_color_rgb(60, 150, 255), a);
        draw_set_blend_mode(bm_add);
        draw_sprite_ext(sprite_index, 3, x, y, 1.2, 0.58, 0, make_color_rgb(80, 170, 255), a * 0.5);
        draw_set_blend_mode(bm_normal);
        for(i = 0; i < 6; i += 1) {
            a = _t * 3 + i * 60;
            draw_sprite_ext(sprite_index, 0, x + lengthdir_x(18, a), y + lengthdir_y(18, a) * 0.5, 0.26, 0.26, 0, make_color_rgb(70, 160, 255), fade);
            draw_set_blend_mode(bm_add);
            draw_sprite_ext(sprite_index, 0, x + lengthdir_x(18, a), y + lengthdir_y(18, a) * 0.5, 0.14, 0.14, 0, make_color_rgb(150, 220, 255), fade);
            draw_set_blend_mode(bm_normal);
        }
        draw_sprite_ext(sprite_index, 0, x, y - _master.sprite_height * 0.5, 1.1, 1.4, 0, make_color_rgb(60, 140, 255), 0.25 * fade);
    break;
    case 5: // Masamune's Haste: afterimages trailing behind him
        a = 5 + sin(_t * 0.3) * 2;
        draw_sprite_ext(_master.sprite_index, _master.image_index, x - lengthdir_x(a * 1.8, _master._direction), y - lengthdir_y(a * 1.8, _master._direction), 1, 1, 0, make_color_rgb(150, 220, 255), 0.18 * fade);
        draw_sprite_ext(_master.sprite_index, _master.image_index, x - lengthdir_x(a, _master._direction), y - lengthdir_y(a, _master._direction), 1, 1, 0, make_color_rgb(170, 230, 255), 0.32 * fade);
        draw_sprite_ext(sprite_index, 3, x, y, 1.1, 0.5, _t * 2, make_color_rgb(120, 230, 140), 0.45 * fade);
    break;
    case 6: // Vampire: a red haze and a pair of glowing eyes' worth of menace
        draw_sprite_ext(sprite_index, 0, x, y - _master.sprite_height * 0.45, 0.9, 1.1, 0, make_color_rgb(170, 0, 30), 0.35 * fade);
        draw_set_blend_mode(bm_add);
        draw_sprite_ext(sprite_index, 0, x, y - _master.sprite_height * 0.45, 0.45, 0.55, 0, make_color_rgb(200, 30, 50), 0.35 * fade);
        draw_set_blend_mode(bm_normal);
    break;
    case 7: // Zio's Magic Barrier: his own glow strips, frame for frame, pulsing; brighter as it's fresher
        if(_master._absorbamount <= 0 || _master._absorbmax <= 0) break;
        a = 0.45 + 0.55 * min(1, _master._absorbamount / _master._absorbmax);
        draw_sprite_ext(spr_zio_barrier, _master.image_index, x, y, 1, 1, 0, c_white, a * (0.35 + 0.1 * sin(_t * 0.12)));
        draw_set_blend_mode(bm_add);
        draw_sprite_ext(spr_zio_barrier, _master.image_index, x, y, 1, 1, 0, c_white, a * (0.4 + 0.15 * sin(_t * 0.12)));
        draw_set_blend_mode(bm_normal);
        draw_sprite_ext(spr_zio_barrier_edge, _master.image_index, x, y, 1, 1, 0, c_white, min(1, a * 0.7 + _hit * 0.08));
        if(_hit > 0) {
            draw_set_blend_mode(bm_add);
            draw_sprite_ext(spr_zio_barrier_edge, _master.image_index, x, y, 1, 1, 0, c_white, _hit * 0.1);
            draw_set_blend_mode(bm_normal);
        }
    break;
    case 8: // Black Wave curse: a dark haze (the rising wisps are particles)
        draw_sprite_ext(sprite_index, 0, x, y - _master.sprite_height * 0.4, 0.8, 1, 0, make_color_rgb(30, 10, 45), 0.35 * fade);
    break;
    case 4: // Shadow Word: Pain: a dark haze around the target (the rising wisps are particles)
        draw_sprite_ext(sprite_index, 0, x, y - _master.sprite_height * 0.4, 0.8, 1, 0, make_color_rgb(90, 30, 130), 0.3 * fade);
    break;
}
