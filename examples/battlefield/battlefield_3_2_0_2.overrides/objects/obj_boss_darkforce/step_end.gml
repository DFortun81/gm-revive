// Dark Force (gm-revive overrides: the game's own end step, changed as in the Call to Arms version of the
// fight). Supreme Black Wave now takes 30 s to charge, and the unit it will hit is chosen when the
// charge starts and marked (see the draw event), so you can see it coming. The face also bobs as it
// hovers, which the original meant to do (it reset the bob every step).
var size, path, dir;
if(global.toggle_pause) exit;
if(_ydir == 0) {
    _ydif -= 0.1;
    if(_ydif < -3) _ydir = 1;
}
else {
    _ydif += 0.1;
    if(_ydif > 3) _ydir = 0;
}
if(global.cutscene_ending) exit;

_blackwave_cooldown -= 1;
if(instance_exists(_master)) {
    x = _master.x;
    y = _master.y;
    // keep the face on screen: when Zio is near the top it hovers lower over him (no lower than 40 px),
    // easing there so it doesn't jump. 56 is the face sprite's y origin, plus room for the bob and cast bar.
    _height += (max(40, min(130, y - view_yview[0] - 56 - 12)) - _height) / 8;
    size = ds_list_size(_master._enemylist);
    if(size <= 0) {
        _attackcastwait = 0;
        _casting = false;
        _target = -1;
        image_alpha -= image_alpha / 10;
        if(image_alpha < 0.02) instance_destroy();
    }
    else {
        if(_powerup) image_alpha += ((_master.image_alpha - 0.4) - image_alpha) / 10;
        else if(image_alpha > 0.8) _powerup = true;
        if(!_casting) {
            // Dark Force Special Ability: Supreme Black Wave, at a unit chosen now
            if(_blackwave_cooldown < 0) {
                _target = ds_list_find_value(_master._enemylist, irandom(size - 1));
                if(units_exists(_target)) {
                    _casting = true;
                    _attackcasttime = _blackwave_casttime;
                    _attackcastwait = 0;
                    create_text_effect(_target.x, _target.y, c_purple, "-marked by dark force-"); boss_sfx(snd_bfx_marked);
                    exit;
                }
            }
        }
        else {
            // The marked unit died or left: mark another, so the wave isn't wasted
            if(!units_exists(_target)) _target = ds_list_find_value(_master._enemylist, irandom(size - 1));
            else if(_target.dead) _target = ds_list_find_value(_master._enemylist, irandom(size - 1));
            _attackcasttime = _blackwave_casttime;
            _attackcastwait += 1;
            if(_attackcastwait >= _attackcasttime && units_exists(_target)) {
                // Cast Successful
                // (gm-revive overrides) a dark bolt from the face to the marked unit; the pillar comes down with
                // the blow itself (alarm 3)
                zio_blackwave_fx(x, y, _height - _ydif + 26, _target, false);
                _savedtarget = _target;
                _attackcastwait = 0;
                _casting = false;
                _target = -1;
                sound_play(snd_bigblackwave);
                obj_sky._alpha = 0.4;
                alarm[0] = 1;
                exit;
            }
        }
    }
}
else {
    obj_sky._alpha = 0;
    instance_destroy();
}
depth = -(y - 2);
