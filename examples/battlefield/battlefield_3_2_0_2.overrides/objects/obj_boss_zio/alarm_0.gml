// (gm-revive overrides) The first time Zio appears in a session he plays the long first meeting from the
// Call to Arms version (zio_intro_line, run from the begin step); after that, the game's short intro.
_desty = y + 24;
if(!variable_global_exists("zio_met")) {
    global.zio_met = true;
    _talk = 0;
    _talk_timer = 10;
    _talk_on = true;
    _talk_t1 = -1; _talk_t2 = -1; _talk_t3 = -1; _talk_t4 = -1;
}
else alarm[1] = 10;
