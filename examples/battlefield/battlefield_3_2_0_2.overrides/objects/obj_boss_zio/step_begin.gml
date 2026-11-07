// (gm-revive overrides) The game's own begin step, plus the long first meeting (zio_intro_line)
if(variable_local_exists("_talk_on")) {
    if(_talk_on && !global.toggle_pause) {
        _talk_timer -= 1;
        if(_talk_timer <= 0) zio_intro_line();
    }
}
if((_health / _maxhealth) <= 0.1) {
    _blackwave_amount = 240;
    _hewn_amount = 100;
    _corrsion_amount = 80;
    
    if(_blackwave_cooldown_time == room_speed * 0.1) create_text_effect(x, y, c_white, "-empowered (rank 1)-");
    _blackwave_cooldown_time = 0;
    
    _blackwave_casttime = room_speed * 1; // (gm-revive overrides) was 0.5 s: two raid members a second // <-- Equivalent to 0.5 second under perfect conditions
    _nightmare_casttime = room_speed * 0.75; // <-- Equivalent to 0.75 second under perfect conditions
    _hewn_casttime = room_speed * 1; // <-- Equivalent to 1 second under perfect conditions
    _corrsion_casttime = room_speed * 0.25; // <-- Equivalent to 0.25 second under perfect conditions
}
else if((_health / _maxhealth) <= 0.5) {
    _blackwave_amount = 170;
    _hewn_amount = 76;
    _corrsion_amount = 63;
    
    if(_blackwave_cooldown_time == room_speed * 0.2) create_text_effect(x, y, c_white, "-empowered (rank 2)-");
    _blackwave_cooldown_time = room_speed * 0.1;
    
    _blackwave_casttime = room_speed * 1.5; // <-- Equivalent to 1.5 seconds under perfect conditions
    _nightmare_casttime = room_speed * 1; // <-- Equivalent to 1 second under perfect conditions
    _hewn_casttime = room_speed * 1.5; // <-- Equivalent to 1.5 seconds under perfect conditions
    _corrsion_casttime = room_speed * 0.5; // <-- Equivalent to 0.5 second under perfect conditions
}

if(global.cutscene_focus == id) {
    if(global.cutscene_ending && !_cutscene_ending_started) {
        alarm[8] = 120;
        _casting = false;
        _attackcastwait = 0;
        image_single = 0;
        _cutscenemessage = "This... this can't be!";
        _cutscene_ending_started = true;
    }
}
event_inherited();