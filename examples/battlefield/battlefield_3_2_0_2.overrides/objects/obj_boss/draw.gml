// obj_boss (gm-revive overrides: the game's own draw event, with the death silhouette fixed below)
var barsize;
barsize = 16;

if(!_stealthed) _stealthed_alpha += (image_alpha - _stealthed_alpha) / 10;
else _stealthed_alpha += (0.1 - _stealthed_alpha) / 10;

// (gm-revive overrides) Count Vaelric out of phase after Mist Step: nothing to draw (not even his bars)
if(object_index == obj_boss_elmdor && variable_local_exists("_phase_time")) { if(_phase_time > 0) exit; }

// (gm-revive overrides) Count Vaelric's red glow (his glow strip from the later version of the game)
// pulses round him while Blood Suck drains someone, and flares each time it heals him
var vg, vfx, vfy, vtx, vty, vi, vn, vt, vpx, vpy, vqx, vqy, vk;
vg = 0;
if(object_index == obj_boss_elmdor && variable_local_exists("_drain_victim")) {
    if(_bloodsuck_casting && _drain_victim != -1) vg = 0.45 + 0.15 * sin(current_time / 120) + _drain_pulse * 0.04;
}
if(vg > 0) {
    draw_sprite_ext(spr_vaelric_glow, image_index, x, y + 2, 1.3, 1.18, 0, c_white, vg * 0.8 * _stealthed_alpha);
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(spr_vaelric_glow, image_index, x, y + 2, 1.3, 1.18, 0, c_white, vg * 0.35 * _stealthed_alpha);
    draw_set_blend_mode(bm_normal);
}
draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, -45, c_black, _stealthed_alpha / 10);
draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, _blendcolor, _stealthed_alpha);
// and a faint red sheen over him while he feeds
if(vg > 0) {
    draw_set_blend_mode(bm_add);
    draw_sprite_ext(spr_vaelric_glow, image_index, x, y, 1, 1, 0, c_white, vg * 0.22 * _stealthed_alpha);
    draw_set_blend_mode(bm_normal);
}
// (gm-revive overrides) Blood Suck: a wavy ribbon of blood from the victim's chest to his mouth, with
// drops running along it toward him
if(vg > 0 && units_exists(_drain_victim)) {
    vfx = _drain_victim.x; vfy = _drain_victim.y - _drain_victim.sprite_height * 0.55;
    vtx = x; vty = y - sprite_height * 0.62;
    vk = 1 - _attackcastwait / max(1, _attackcasttime);   // how far the drain has got (it quickens)
    vn = 16; vpx = vfx; vpy = vfy;
    for(vi = 1; vi <= vn; vi += 1) {
        vt = vi / vn;
        vqx = vfx + (vtx - vfx) * vt;
        vqy = vfy + (vty - vfy) * vt - sin(vt * pi) * 12 + sin(vt * 14 - current_time / 70) * 2 * sin(vt * pi);
        draw_set_alpha(0.6);
        draw_set_color(make_color_rgb(80, 0, 10));
        draw_line_width(vpx, vpy, vqx, vqy, 4 + 3 * vk);
        draw_set_alpha(0.9);
        draw_set_color(make_color_rgb(200, 20, 35));
        draw_line_width(vpx, vpy, vqx, vqy, 1.5 + 1.5 * vk);
        vpx = vqx; vpy = vqy;
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    for(vi = 0; vi < 6; vi += 1) {
        vk = frac(current_time / 650 + vi / 6);
        vqx = vfx + (vtx - vfx) * vk;
        vqy = vfy + (vty - vfy) * vk - sin(vk * pi) * 12 + sin(vk * 14 - current_time / 70) * 2 * sin(vk * pi);
        draw_sprite_ext(spr_fx_misc, 0, vqx, vqy, 0.26, 0.26, 0, make_color_rgb(150, 0, 15), 0.9);
        draw_set_blend_mode(bm_add);
        draw_sprite_ext(spr_fx_misc, 0, vqx, vqy, 0.14, 0.14, 0, make_color_rgb(255, 60, 70), 0.9);
        draw_set_blend_mode(bm_normal);
    }
}
// (gm-revive overrides) The white flash as a boss dies used one silhouette made from frame 0 (facing
// south), so it didn't line up when the boss faced any other way. Zio and Count Vaelric now have a white
// silhouette for every frame of their sprites, and the one for the frame they're showing is drawn.
if(_overlay_alpha > 0) {
    if(object_index == obj_boss_zio) draw_sprite_ext(spr_zio_death, image_index, x, y, 1, 1, 0, c_white, _overlay_alpha);
    else if(object_index == obj_boss_elmdor) draw_sprite_ext(spr_vaelric_death, image_index, x, y, 1, 1, 0, c_white, _overlay_alpha);
    else draw_background_ext(_overlay_back, x - sprite_xoffset, y - sprite_yoffset, 1, 1, 0, c_white, _overlay_alpha);
}

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

if(_attackcastwait > 0 && _silenced <= 0) { // (gm-revive overrides) none during an interrupt's lockout
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