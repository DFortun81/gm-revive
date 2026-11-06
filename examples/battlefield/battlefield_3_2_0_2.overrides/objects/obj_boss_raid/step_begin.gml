// Raid bosses die like normal units (obj_boss would start the death cutscene)
if(_health <= 0 && !dead) {
    dead = true;
    _health = 0;
    _message = "";
    _raid_casting = false;
    sound_stop_all();
    sound_play(snd_defeated);
    create_text_effect(x, y, c_white, "-defeated-");
}
event_inherited();
