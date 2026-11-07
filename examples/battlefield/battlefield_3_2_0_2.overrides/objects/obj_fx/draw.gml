// Each particle is drawn in its true colour first (additive light alone turns everything white on the
// bright grass), then, if _add, a smaller additive copy on top gives it a glowing centre.
var t, f, s, ys, ang, a, i, n, k, px, py;
t = _life / _maxlife;
ys = 1; ang = 0;
switch(_kind) {
    case 0: f = 0; s = _size * (1 + (_grow - 1) * t); ys = _squash; a = _alpha * (1 - t); break;            // flash
    case 1: f = 2; s = _size * (0.25 + 0.75 * sqrt(t)); ys = _squash; a = _alpha * (1 - t); break;          // ring
    case 2: f = 7; s = _size * (0.7 + 0.3 * sin(_life * 0.7)); ang = image_angle; a = _alpha * (1 - t); break; // sparkle
    case 3: f = 6; s = _size; ang = image_angle; a = _alpha * (1 - t * t); break;                             // shard
    case 4: f = 0; s = _size; a = _alpha * min(1, _life / 5); break;                                          // mote
    case 5: f = 0; s = _size * (1 - t * 0.6); a = _alpha * (1 - t); break;                                    // streak
    case 6: f = 1; s = _size; ang = image_angle; a = _alpha * (1 - t); break;                                 // star
    case 7: f = 4; s = _size * (0.85 + 0.3 * t); ang = image_angle; a = _alpha * (1 - t); break;             // slash
}
if(_kind == 5) n = 12; else n = 0;
// Slashes get a dark backing so they stand out on the bright grass
if(_kind == 7) draw_sprite_ext(sprite_index, f, x + 1, y - _h + 1, s * 1.08, s * 1.08, ang, c_black, a * 0.45);
for(k = 0; k < 2; k += 1) {
    if(k == 1) {
        if(!_add) break;
        draw_set_blend_mode(bm_add);
        s *= 0.55; a *= 0.7;
    }
    if(_kind == 5) {
        // streak: a beam of glows from (_x1, _y1) to here, brightest at this end
        for(i = 0; i <= n; i += 1) {
            px = _x1 + (x - _x1) * i / n;
            py = (_y1 - _h1) + ((y - _h) - (_y1 - _h1)) * i / n;
            draw_sprite_ext(sprite_index, f, px, py, s, s, 0, _col, a * (0.35 + 0.65 * i / n));
        }
    }
    else draw_sprite_ext(sprite_index, f, x, y - _h, s, s * ys, ang, _col, a);
}
draw_set_blend_mode(bm_normal);
