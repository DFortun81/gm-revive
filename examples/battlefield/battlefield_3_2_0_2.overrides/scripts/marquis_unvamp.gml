// marquis_unvamp(unit);
// A vampire comes back to its senses and its side. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
with(argument0) {
    if(_vamp_timer <= 0) exit;
    _vamp_timer = 0;
    _faction = _vamp_faction;
    if(_blendcolor == make_color_rgb(255, 120, 120)) _blendcolor = c_white;
    _target = -1;
    _casting = false;
    _attackcastwait = 0;
    _message = "";
    if(!dead) create_text_effect(x, y, c_white, "-vampire fades-");
}
