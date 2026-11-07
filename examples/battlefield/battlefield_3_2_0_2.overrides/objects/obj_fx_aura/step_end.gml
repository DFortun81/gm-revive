var on, p;
if(global.toggle_pause) exit;
if(!instance_exists(_master)) { instance_destroy(); exit; }
_t += 1;
x = _master.x; y = _master.y;
if(_kind == 2 || _kind == 3 || _kind == 5 || _kind == 7) depth = _master.depth + 1; // behind the unit
else depth = _master.depth - 1;
on = !_master.dead;
switch(_kind) {
    case 0: on = on && _master._stunned; break;
    case 1: on = on && _master._blendcolor == c_yellow; break;
    case 2: on = on && _master._evasion_timer > 0; break;
    case 3: on = on && _master._evocation_casting; break;
    case 4: on = on && instance_exists(_src); if(on) on = _src._swp_timer > 0 && _src._swp_target == _master; break;
    case 5: on = on && _master._haste_timer > 0; break;
    case 6: on = on && _master._vamp_timer > 0; break;
    case 7: on = true; break; // stays for the whole fight; draws only while the barrier holds
    case 8: on = on && _master._zio_curse > 0; break;
    case 15: on = on && _master._bloodrage_timer > 0; break;
    case 16: on = on && _master._laststand_timer > 0; break;
    case 13: on = on && _master._stunned; break;
    case 14: on = on && _master._stunned; break;
    case 12: on = on && _master._blight_timer_on > 0; break;
    case 11: on = on && _master._acid_timer > 0; break;
    case 10: on = on && _master._thrall_timer > 0; break;
    case 9: on = on && instance_exists(_src); if(on) on = _src._bloodsuck_casting && _src._drain_victim == _master; break;
}
if(_ending < 0) {
    if(!on) {
        _ending = 10;
        if(_kind == 13) { // the ice shatters
            repeat(10) {
                p = fx_make(3, x, y, random(_master.sprite_height), make_color_rgb(190, 235, 255), random_range(0.3, 0.45), 22);
                p._vx = random_range(-2, 2); p._vy = random_range(-0.8, 0.8); p._vh = random_range(0.5, 2.2); p._grav = 0.14;
                p._spin = random_range(-15, 15); p.image_angle = random(360);
            }
            with(fx_make(0, x, y, _master.sprite_height * 0.5, make_color_rgb(200, 240, 255), 1, 10)) _grow = 1.6;
        }
        if(_kind == 14) { // the web tears
            repeat(8) {
                p = fx_make(5, x + random_range(-14, 14), y + random_range(-6, 6), random(_master.sprite_height), make_color_rgb(235, 235, 225), 0.12, 14);
                p._x1 = x; p._y1 = y; p._h1 = _master.sprite_height * 0.5; p._add = false;
            }
        }
        if(_kind == 1) { // the bubble pops
            p = fx_make(1, x, y, _master.sprite_height * 0.45, make_color_rgb(255, 215, 90), 1.3, 14);
            repeat(5) { p = fx_make(2, x + random_range(-10, 10), y, random(_master.sprite_height), make_color_rgb(255, 225, 120), 0.35, 16); p._vh = 0.4; }
        }
    }
}
else {
    _ending -= 1;
    if(_ending <= 0) { instance_destroy(); exit; }
}
if(_ending < 0) {
    if(_kind == 1 && _t mod 9 == 0) {
        p = fx_make(2, x + random_range(-11, 11), y, random_range(4, _master.sprite_height), make_color_rgb(255, 230, 140), 0.3, 18);
        p._vh = 0.3;
    }
    if(_kind == 3 && _t mod 2 == 0) {
        p = fx_make(4, x, y, random(30), make_color_rgb(60, 160, 255), random_range(0.28, 0.36), 45);
        if(irandom(2) == 0) p._col = make_color_rgb(150, 90, 255);
        p._master = _master; p._ang = random(360); p._rad = 24 + random(10);
        p._ch = _master.sprite_height * 0.5; p._spin = 8;
    }
    if(_kind == 5 && _t mod 10 == 0) {
        // Regen: green motes rising off him
        p = fx_make(2, x + random_range(-10, 10), y, random_range(4, _master.sprite_height), make_color_rgb(130, 255, 150), 0.35, 20);
        p._vh = 0.6;
    }
    if(_kind == 6 && _t mod 9 == 0) {
        // Vampire: a drop of blood now and then
        p = fx_make(0, x + random_range(-5, 5), y, random_range(8, _master.sprite_height * 0.8), make_color_rgb(150, 0, 20), 0.18, 22);
        p._add = false; p._vh = -0.5; p._grow = 0.6;
    }
    if(_kind == 7) {
        // Magic Barrier: flash the outline when it takes a hit, shatter when it breaks
        if(_master._absorbamount < _last_absorb) _hit = 8;
        if(_last_absorb > 0 && _master._absorbamount <= 0) {
            with(fx_make(1, x, y, _master.sprite_height * 0.5, make_color_rgb(80, 180, 255), 1.6, 16)) _squash = 1;
            repeat(10) {
                p = fx_make(3, x, y, random(_master.sprite_height), make_color_rgb(90, 190, 255), random_range(0.3, 0.45), 22);
                p._vx = random_range(-1.8, 1.8); p._vy = random_range(-0.8, 0.8); p._vh = random_range(0.5, 2); p._grav = 0.12;
                p._spin = random_range(-15, 15); p.image_angle = random(360);
            }
            create_text_effect(x, y, c_aqua, "-barrier broken-");
            sound_play(snd_zio_barrier_break);
            fs_note("Magic Barriers broken");
        }
        if(_master._absorbamount > _last_absorb && _last_absorb <= 0) {
            with(fx_make(1, x, y, _master.sprite_height * 0.5, make_color_rgb(120, 210, 255), 1.4, 14)) _squash = 1;
            sound_play(snd_zio_barrier);
        }
        _last_absorb = _master._absorbamount;
        if(_hit > 0) _hit -= 1;
    }
    if(_kind == 8 && _t mod 6 == 0) {
        // the curse: black wisps rising off the unit
        p = fx_make(0, x + random_range(-7, 7), y, random_range(6, _master.sprite_height * 0.8), make_color_rgb(25, 10, 35), 0.3, 24);
        p._add = false; p._vh = 0.4; p._grow = 1.8; p._alpha = 0.7;
    }
    if(_kind == 15 && _t mod 4 == 0) {
        // Bloodrage: red steam boiling off her
        p = fx_make(0, x + random_range(-10, 10), y, random(_master.sprite_height * 0.8), choose(make_color_rgb(200, 30, 30), make_color_rgb(120, 10, 10)), random_range(0.2, 0.35), 24);
        p._add = false; p._vh = random_range(0.8, 1.4); p._grow = 1.6; p._alpha = 0.7;
    }
    if(_kind == 16 && _t mod 7 == 0) {
        p = fx_make(2, x + random_range(-10, 10), y, random(_master.sprite_height), make_color_rgb(255, 215, 110), 0.3, 22);
        p._vh = 0.7;
    }
    if(_kind == 12) {
        // Festering Blight: flies buzzing round the sores, and spores
        if(_t mod 4 == 0) {
            p = fx_make(0, x + random_range(-11, 11), y, random_range(6, _master.sprite_height * 0.9), make_color_rgb(15, 15, 5), 0.1, 10);
            p._add = false; p._vx = random_range(-1.2, 1.2); p._vh = random_range(-0.6, 0.6); p._grow = 1;
        }
        if(_t mod 11 == 0) {
            p = fx_make(9, x + random_range(-6, 6), y, random_range(6, _master.sprite_height * 0.7), make_color_rgb(170, 210, 60), 0.3, 18);
            p._vh = 0.45; p._grow = 1.4;
        }
    }
    if(_kind == 11 && _t mod 8 == 0) {
        // Corrosion: an acid bubble now and then
        p = fx_make(9, x + random_range(-8, 8), y, random_range(4, _master.sprite_height * 0.8), make_color_rgb(160, 235, 50), 0.22, 14);
        p._vh = 0.3;
    }
    if(_kind == 4 && _t mod 7 == 0) {
        p = fx_make(0, x + random_range(-7, 7), y, random_range(6, _master.sprite_height * 0.8), make_color_rgb(150, 60, 200), 0.3, 22);
        p._add = false; p._vh = 0.35; p._grow = 1.8; p._alpha = 0.6;
    }
}
