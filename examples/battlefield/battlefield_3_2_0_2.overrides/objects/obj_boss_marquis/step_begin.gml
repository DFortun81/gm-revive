// When the Marquis falls, Celia and Lede fall with him and every vampire comes back to its senses
if(_health <= 0 && !dead) {
    with(obj_marquis_assassin) if(_master == other.id && !dead) { _health = 0; _reborn = true; dead = true; }
    with(obj_unit) if(variable_local_exists("_vamp_timer")) { if(_vamp_timer > 0) marquis_unvamp(id); }
}
event_inherited();
