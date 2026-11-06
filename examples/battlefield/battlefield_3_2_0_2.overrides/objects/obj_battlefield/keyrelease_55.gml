// (gm-revive overrides) Key 7, twice within 2 seconds: clear the saved match results
if(current_time - global.match_clear_armed < 2000) {
    match_clear();
    global.match_clear_armed = 0;
}
else global.match_clear_armed = current_time;
