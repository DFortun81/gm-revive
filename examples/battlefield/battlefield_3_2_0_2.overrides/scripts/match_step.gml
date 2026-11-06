// match_step();
// Called every step by obj_battlefield: notices when one side has been wiped out (or the 3 minute
// time limit is up), records the result, shows it for 5 seconds and starts the next match.
// Boss fights are left to the original game-over screen. An empty field (F2) is a sandbox.
////////////////////////////////////////////////////////////////////////////////////////////
var a, h, bossup;
if(global.toggle_pause || global.cutscene_active) exit;
// A boss spawned by hand (0, 9, 8) during a normal match is left to the original game
if(global.match_format != 5 && instance_exists(obj_boss)) exit;
if(global.match_over) {
    global.match_end_timer -= 1;
    if(global.match_end_timer <= 0 && global.match_auto) room_restart();
    exit;
}
global.match_steps += 1;
a = 0; h = 0;
with(obj_unit) {
    if(!dead && _jobclass != class_mirrorimage && _bossid == -1) {
        if(_faction == "Alliance") a += 1;
        else if(_faction == "Horde") h += 1;
    }
}
if(global.match_format == 5) {
    // Boss: the raid wins when Stitchgut dies, loses if it wipes or after 5 minutes
    bossup = false;
    with(obj_boss_stitchgut) if(!dead) bossup = true;
    if(!bossup || a == 0 || global.match_steps > room_speed * 300) {
        if(!bossup) global.match_winner = "Alliance";
        else global.match_winner = "Stitchgut";
        if(global.match_auto) match_record();
        global.match_over = true;
        global.match_end_timer = room_speed * 5;
    }
    exit;
}
if(a == 0 && h == 0) exit;
if(a == 0 || h == 0 || global.match_steps > room_speed * 180) {
    if(h == 0 && a > 0) global.match_winner = "Alliance";
    else if(a == 0 && h > 0) global.match_winner = "Horde";
    else global.match_winner = "";
    if(global.match_auto) match_record();
    global.match_over = true;
    global.match_end_timer = room_speed * 5;
}
