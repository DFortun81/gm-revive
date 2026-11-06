var barsize;
barsize = 16;

if(!_stealthed) _stealthed_alpha += (image_alpha - _stealthed_alpha) / 10;
else _stealthed_alpha += (0.1 - _stealthed_alpha) / 10;

// (gm-revive overrides) obj_boss's draw at the boss's own size (image_xscale / image_yscale), without
// the death-cutscene overlay raid bosses never use
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, -45, c_black, _stealthed_alpha / 10);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, 0, _blendcolor, _stealthed_alpha);

draw_set_alpha(.5);
draw_set_color(c_black);

draw_healthbar(x - barsize, y - (sprite_height + 14), x + barsize, y - (sprite_height + 10), (_health / _maxhealth) * 100, c_white, c_red, c_green, 0, false, false);
if(_absorbmax > 0 && _absorbamount > 0) {
    draw_healthbar(x - barsize, y - (sprite_height + 14), x + barsize, y - (sprite_height + 10), (_absorbamount / _absorbmax) * 100, c_white, c_blue, c_blue, 0, false, false);
}

if(_manatype >= 0) {
    var c, m, mmax;
    switch(_manatype) {
        case manatype_mana:
            c = c_blue;
            m = _manatype_mana;
            mmax = _manatype_maxmana;
        break;
        case manatype_rage:
            c = c_red;
            m = _manatype_rage;
            mmax = _manatype_maxrage;
        break;
        case manatype_energy:
            c = c_yellow;
            m = _manatype_energy;
            mmax = _manatype_maxenergy;
        break;
    }
    draw_healthbar(x - barsize, y - (sprite_height + 10), x + barsize, y - (sprite_height + 6), (m / mmax) * 100, c_white, c, c, 0, false, false);
    draw_rectangle(x - barsize, y - (sprite_height + 14), x + barsize, y - (sprite_height + 6), true);
}
else {
    draw_rectangle(x - barsize, y - (sprite_height + 14), x + barsize, y - (sprite_height + 10), true);
}
draw_set_alpha(1);

if(_attackcastwait > 0) {
    draw_set_alpha(.5);
    draw_set_color(c_black);
    draw_healthbar(x - barsize, y - (sprite_height + 4), x + barsize, y - sprite_height, (_attackcastwait / _attackcasttime) * 100, c_white, c_blue, c_blue, 0, false, false);
    draw_rectangle(x - barsize, y - (sprite_height + 4), x + barsize, y - sprite_height, true);
    draw_set_alpha(1);
}

draw_set_font(fnt_normal);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(x, y - (sprite_height + 32), _message);
draw_set_halign(fa_left);
