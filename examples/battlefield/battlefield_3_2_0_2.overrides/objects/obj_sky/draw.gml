winskin_step();

if(instance_exists(obj_battlefield)) {
    if(obj_battlefield.gameover) {
        draw_set_color(c_black);
        if(instance_exists(obj_battlefield)) {
            draw_set_alpha(obj_battlefield.gameover_alpha);
        }
        else draw_set_alpha(1);
        draw_rectangle(view_xview[0], view_yview[0], view_xview[0] + view_wview[0], view_yview[0] + view_hview[0], false);
        draw_set_color(c_white);
        draw_set_font(fnt_victory);
        draw_set_halign(fa_center);
        
        var a, b, str;
        a = 0; b = 0;
        with(obj_unit) {
            if(_faction == "Horde") a += 1; else b += 1;
        }
        
        if(a > b) str = "HORDE"; else str = "ALLIANCE";
        draw_text(view_xview[0] + view_wview[0] / 2, view_yview[0] + view_hview[0] / 2, str + " VICTORY!");
    }
    else {
        draw_set_alpha(_alpha);
        draw_set_color(c_black);
        draw_rectangle(view_xview[0], view_yview[0], view_xview[0] + view_wview[0], view_yview[0] + view_hview[0], false);
        draw_set_color(c_white);
        draw_set_alpha(1);
    }
}

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_alpha(1);
draw_set_font(fnt_normal);

var i, ds, size, _x, _y, col, sel, tar, c, m, mmax; sel = -1; tar = -1;
if(global.toggle_numbers) {
    size = ds_list_size(global.text_effect_x);
    for(i = 0;i < size; i += 1) {
        col = ds_list_find_value(global.text_effect_color, i);
        _x = ds_list_find_value(global.text_effect_x, i) + ds_list_find_value(global.text_effect_variance, i);
        _y = ds_list_find_value(global.text_effect_y, i) - ds_list_find_value(global.text_effect_difference, i);
        draw_text_color(_x, _y, ds_list_find_value(global.text_effect_string, i), col, col, col, col, ds_list_find_value(global.text_effect_alpha, i));
    }
}

draw_set_alpha(.5);
draw_set_color(c_black);

_x = view_xview[0] + 20; _y = view_yview[0] + 10;
ds = ds_list_find_value(global.faction_agents, 0);
size = ds_list_size(ds);

draw_window_skinned(view_xview[0], view_yview[0], view_xview[0] + max(20, 10 + ceil(size / ceil((view_hview[0] - 30) / 18)) * 30), view_yview[0] + view_hview[0]);
for(i = 0;i < size; i+= 1) {
    with(ds_list_find_value(ds, i)) {
            if(!dead) {
                draw_healthbar(_x - 12, _y, _x + 12, _y + 4, (_health / _maxhealth) * 100, c_white, c_red, c_green, 0, false, false);
                if(_absorbmax > 0 && _absorbamount > 0) {
                    draw_healthbar(_x - 12, _y, _x + 12, _y + 4, (_absorbamount / _absorbmax) * 100, c_white, c_blue, c_blue, 0, false, false);
                }
                if(_manatype >= 0) {
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
                    draw_healthbar(_x - 12, _y + 4, _x + 12, _y + 8, (m / mmax) * 100, c_white, c, c, 0, false, false);
                    draw_rectangle(_x - 12, _y, _x + 12, _y + 8, true);
                }
                else {
                    draw_rectangle(_x - 12, _y, _x + 12, _y + 4, true);
                }
                
                if(_attackcastwait > 0 && _silenced <= 0) {
                    draw_healthbar(_x - 12, _y + 10, _x + 12, _y + 14, (_attackcastwait / _attackcasttime) * 100, c_white, c_blue, c_blue, 0, false, false);
                    draw_rectangle(_x - 12, _y + 10, _x + 12, _y + 14, true);
                }
            }
            else {
                // Draw Partial rectangle
                draw_set_alpha(image_alpha);
                draw_set_color(image_blend);
                draw_rectangle(_x - 12, _y, _x + 12, _y + 14, false);
                draw_set_color(c_black);
                draw_set_alpha(.5);
            }
            _y += 18;
            if(_y >= (view_yview[0] + view_hview[0]) - 20) {
                _x += 30;
                _y = view_yview[0] + 10;
        }
    }
}

draw_set_halign(fa_left);
for(i = 0;i < ds_list_size(global._global_text);i += 1) {
    draw_text(_x + 30, 10 + 20 * i, string(ds_list_find_value(global._global_text, i)));
}

// Draw the selected unit and his cooldowns
sel = obj_battlefield.selected;
if(sel != -1 && instance_exists(sel)) {
    view_object[0] = sel;
    draw_window_skinned(_x + 20, view_yview[0] + view_hview[0] - 80, _x + 200, view_yview[0] + view_hview[0]);
    draw_text(_x + 34, view_yview[0] + view_hview[0] - 70, "[" + string(sel) + "]: " + string(sel._faction) + " " + unit_get_name(sel));
    draw_text(_x + 34, view_yview[0] + view_hview[0] - 50, string(sel._health) + " / " + string(sel._maxhealth));
    if(sel._manatype >= 0) {
        switch(sel._manatype) {
            case manatype_mana:
                c = c_blue;
                m = sel._manatype_mana;
                mmax = sel._manatype_maxmana;
            break;
            case manatype_rage:
                c = c_red;
                m = sel._manatype_rage;
                mmax = _manatype_maxrage;
            break;
            case manatype_energy:
                c = c_yellow;
                m = sel._manatype_energy;
                mmax = _manatype_maxenergy;
            break;
        }
        draw_text(_x + 34, view_yview[0] + view_hview[0] - 30, string(m) + " / " + string(mmax));
    }
    if(instance_exists(sel._target)) {
        if(!(sel._target.dead)) tar = sel._target; else tar = -1; 
    }
    else tar = -1;
    
    var size, i, index;
    size = ds_list_size(sel._enemylist);
    if(size > 0) {
        draw_window_skinned(_x + 200, view_yview[0] + view_hview[0] - size * 20 - 4, _x + 360, view_yview[0] + view_hview[0]);
        for(i = 0;i < size; i += 1;) {
            index = ds_list_find_value(sel._enemylist, i);
            if(instance_exists(index)) {
                draw_text(_x + 210, view_yview[0] + view_hview[0] - (i + 1) * 20, "[" + string(index) + "]: " + string(index._faction) + " " + unit_get_name(index));
            }
        }
    }
    // (gm-revive overrides) the selected unit's cooldowns, next to its enemy list
    if(size > 0) job_draw_cooldowns(sel, true, _x + 360, view_yview[0] + view_hview[0]);
    else job_draw_cooldowns(sel, true, _x + 200, view_yview[0] + view_hview[0]);
}



draw_set_halign(fa_center);

_x = view_xview[0] + view_wview[0] - 20;
_y = view_yview[0] + 10;
ds = ds_list_find_value(global.faction_agents, 1);
size = ds_list_size(ds);

draw_window_skinned(view_xview[0] + view_wview[0] - max(20, (10 + ceil(size / ceil((view_hview[0] - 30) / 18)) * 30)), view_yview[0], view_xview[0] + view_wview[0], view_yview[0] + view_hview[0]);
for(i = 0;i < ds_list_size(ds); i+= 1) {
    with(ds_list_find_value(ds, i)) {
        if(!dead) {
            draw_healthbar(_x - 12, _y, _x + 12, _y + 4, (_health / _maxhealth) * 100, c_white, c_red, c_green, 0, false, false);
            if(_absorbmax > 0 && _absorbamount > 0) {
                draw_healthbar(_x - 12, _y, _x + 12, _y + 4, (_absorbamount / _absorbmax) * 100, c_white, c_blue, c_blue, 0, false, false);
            }
            if(_manatype >= 0) {
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
                draw_healthbar(_x - 12, _y + 4, _x + 12, _y + 8, (m / mmax) * 100, c_white, c, c, 0, false, false);
                draw_rectangle(_x - 12, _y, _x + 12, _y + 8, true);
            }
            else {
                draw_rectangle(_x - 12, _y, _x + 12, _y + 4, true);
            }
            
            if(_attackcastwait > 0 && _silenced <= 0) {
                draw_healthbar(_x - 12, _y + 10, _x + 12, _y + 14, (_attackcastwait / _attackcasttime) * 100, c_white, c_blue, c_blue, 0, false, false);
                draw_rectangle(_x - 12, _y + 10, _x + 12, _y + 14, true);
            }
        }
        else {
            // Draw Partial rectangle
            draw_set_alpha(image_alpha);
            draw_set_color(image_blend);
            draw_rectangle(_x - 12, _y, _x + 12, _y + 14, false);
            draw_set_color(c_black);
            draw_set_alpha(.5);
        }
        
        _y += 18;
        if(_y >= view_yview[0] + view_hview[0] - 20) {
            _x -= 30;
            _y = view_yview[0] + 10;
        }
    }
}

draw_set_halign(fa_left);
if(tar != -1 && instance_exists(tar)) {
    draw_window_skinned(_x - 210, view_yview[0] + view_hview[0] - 80, _x - 20, view_yview[0] + view_hview[0]);
    draw_text(_x - 200, view_yview[0] + view_hview[0] - 70, "[" + string(tar) + "]: " + string(tar._faction) + " " + unit_get_name(tar));
    draw_text(_x - 200, view_yview[0] + view_hview[0] - 50, string(tar._health) + " / " + string(tar._maxhealth));
    if(tar._manatype >= 0) {
        switch(tar._manatype) {
            case manatype_mana:
                c = c_blue;
                m = tar._manatype_mana;
                mmax = tar._manatype_maxmana;
            break;
            case manatype_rage:
                c = c_red;
                m = tar._manatype_rage;
                mmax = _manatype_maxrage;
            break;
            case manatype_energy:
                c = c_yellow;
                m = tar._manatype_energy;
                mmax = _manatype_maxenergy;
            break;
        }
        draw_text(_x - 200, view_yview[0] + view_hview[0] - 30, string(m) + " / " + string(mmax));
    }
}

draw_set_halign(fa_center);
draw_set_font(fnt_boss);
ds_list_clear(_bosslist);
with(obj_boss) {
    ds_list_add(other._bosslist, id);
}
ds_list_sort(other._bosslist, 1);

size = ds_list_size(_bosslist);
if(size > 0) {
    var x1, x2, w, w2, h, p, h2, _y2; w = 60; w2 = w - 10; h = 4;
    _x = view_xview[0] + (view_wview[0] / 2); _y = 8;
    x1 = _x - w; x2 = _x + w; p = 2; h2 = (h * 3) + (p * 2) + 16;
    
    draw_window_skinned(x1, view_yview[0], x2, view_yview[0] + 12 + size * h2);
    for(i = 0;i < ds_list_size(_bosslist); i+= 1) {
        with(ds_list_find_value(_bosslist, i)) {
            draw_set_alpha(1);
            draw_set_font(fnt_boss);
            draw_set_color(c_black);
            draw_set_halign(fa_center);
            draw_text(_x, _y, string(_faction) + " " + unit_get_name(id));
            draw_set_alpha(.5);
            _y += 16;
            
            if(!dead) {
                draw_healthbar(_x - w2, _y, _x + w2, _y + h, (_health / _maxhealth) * 100, c_white, c_red, c_green, 0, false, false);
                if(_absorbmax > 0 && _absorbamount > 0) {
                    draw_healthbar(_x - w2, _y, _x + w2, _y + h, (_absorbamount / _absorbmax) * 100, c_white, c_blue, c_blue, 0, false, false);
                }
                if(_manatype >= 0) {
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
                    draw_healthbar(_x - w2, _y + h, _x + w2, _y + (h * 2), (m / mmax) * 100, c_white, c, c, 0, false, false);
                    draw_rectangle(_x - w2, _y, _x + w2, _y + (h * 2), true);
                }
                else {
                    draw_rectangle(_x - w2, _y, _x + w2, _y + h, true);
                }
                
                if(_attackcastwait > 0 && _silenced <= 0) {
                    draw_healthbar(_x - w2, _y + (h * 2) + p, _x + w2, _y + (h * 3) + p, (_attackcastwait / _attackcasttime) * 100, c_white, c_blue, c_blue, 0, false, false);
                    draw_rectangle(_x - w2, _y + (h * 2) + p, _x + w2, _y + (h * 3) + p, true);
                }
            }
            else {
                // Draw Partial rectangle
                draw_set_alpha(image_alpha);
                draw_set_color(image_blend);
                draw_rectangle(_x - w2, _y, _x + w2, _y + (h * 3) + p, false);
                draw_set_color(c_black);
                draw_set_alpha(.5);
            }
            _y += (h * 3) + (p * 2);
            
            //global.cutscene_active && 
            if(global.cutscene_active && _message != "") {
                // Draw the Cutscene Text
                draw_set_font(fnt_message);
                draw_set_color(c_white);
                draw_set_alpha(1);
                w = round(max(string_width(_message) / 2 + 10, 30));
                _y2 = view_yview[0] + 12 + size * h2 + 4 + i * 36;
                draw_window_skinned(_x - w, _y2, _x + w, _y2 + 34);
                draw_set_halign(fa_center);
                draw_text(_x, _y2 + 8, _message);
                draw_set_halign(fa_left);
                draw_set_font(-1);
            }
        }
    }
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_font(fnt_normal);
draw_set_color(c_white);
draw_set_halign(fa_left);

// (gm-revive overrides) Recount-style damage / healing meter, key 4
recount_draw();

// (gm-revive overrides) automatic matches: label, winner banner, results panel (key 5)
match_draw();
