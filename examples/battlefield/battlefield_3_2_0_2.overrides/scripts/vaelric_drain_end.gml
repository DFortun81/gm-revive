// vaelric_drain_end();
// Count Vaelric lets go of whoever he was draining with Blood Suck: it drops back to the ground and gets
// its colour back. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
if(_drain_victim == -1) exit;
if(units_exists(_drain_victim)) {
    _drain_victim.y = _drain_y0;
    _drain_victim._blendcolor = _drain_blend0;
}
_drain_victim = -1;
