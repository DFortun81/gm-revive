// The sheep effect that follows a polymorphed unit (gm-revive overrides: same as the original, except
// that when the sheep wears off it gives the unit back the sprite it had before, saved by
// caster_polymorph_land, instead of looking one up by class. The lookup only knows the playable
// classes, so a polymorphed broodling used to come back wearing Zio's sprite.)
if(global.toggle_pause) exit;
if(_dist > 0) {
    _dist -= (25 - _dist) / 4;
    with(instance_create(x, y, obj_evocation_effect)) {
        image_blend = c_ltgray;
        _progress = other._dist;
    }
}
else _dist = 0;
depth = -y;
if(_master != -1 && instance_exists(_master)) {
    if(_master._polymorphed) _master.sprite_index = spr_hide;
    else {
        _master.sprite_index = _master._polymorphed_sprite;
        repeat(10) {
            with(instance_create(x, y, obj_evocation_effect)) {
                image_blend = c_gray;
                _progress = 0;
            }
        }
        instance_destroy();
    }
}
else instance_destroy();
