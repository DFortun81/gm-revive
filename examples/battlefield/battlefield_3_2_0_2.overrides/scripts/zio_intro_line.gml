// zio_intro_line();
// The long first meeting with Zio, from the Call to Arms version of the fight (its lines are the fort
// scene from Phantasy Star IV). Run by obj_boss_zio's begin step: says line _talk, waits its time, and
// at the end starts the battle (alarm 7, as the short intro does). Speakers: 0 Zio, 1-4 raid members
// picked at random. Each line stays up at least 2.5 s, so quick exchanges overlap. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var spk, txt, t, n, i, u, k;
// pick the raid members who speak
if(_talk == 0) {
    n = 0;
    with(obj_unit) if(_faction != other._faction && !dead && _bossid == -1 && _jobclass != class_mirrorimage) { k[n] = id; n += 1; }
    for(i = 0; i < 4; i += 1) {
        if(n > 0) { u = irandom(n - 1); t[i] = k[u]; if(n > 1) { k[u] = k[n - 1]; n -= 1; } }
        else t[i] = -1;
    }
    _talk_t1 = t[0]; _talk_t2 = t[1]; _talk_t3 = t[2]; _talk_t4 = t[3];
}
switch(_talk) {
    case 0: spk = 0; txt = "Go no further."; _talk_timer = 90; break;
    case 1: spk = 1; txt = "Who is that!?"; _talk_timer = 90; break;
    case 2: spk = 2; txt = "That voice! It's Zio!"; _talk_timer = 30; break;
    case 3: spk = 3; txt = "Wh... what is this?#I feel... this incredible menace!"; _talk_timer = 20; break;
    case 4: spk = 4; txt = "Zio! You son of a...!"; _talk_timer = 50; break;
    case 5: spk = 0; txt = "Watch your tongue."; _talk_timer = 30; break;
    case 6: spk = 0; txt = "So you thought you would sneak in while the master was out, eh, you little sneak thief?"; _talk_timer = 90; break;
    case 7: spk = 2; txt = "Take a good look at yourself before you dare put us down!"; _talk_timer = 80; break;
    case 8: spk = 2; txt = "Think about all you've done!"; _talk_timer = 80; break;
    case 9: spk = 0; txt = "Hmmph. So I've wrought damage to the world."; _talk_timer = 100; break;
    case 10: spk = 0; txt = "What's wrong with eliminating worms?"; _talk_timer = 60; break;
    case 11: spk = 1; txt = "Worms?"; _talk_timer = 20; break;
    case 12: spk = 1; txt = "You dare call us worms?"; _talk_timer = 60; break;
    case 13: spk = 1; txt = "You... you... I CANNOT FORGIVE YOU!"; _talk_timer = 30; break;
    case 14: spk = 0; txt = "Heh, heh, heh."; _talk_timer = 20; break;
    case 15: spk = 0; txt = "Now, now. That's the expression I want to see!"; _talk_timer = 90; break;
    case 16: spk = 0; txt = "A face filled with pain and anguish,#begging fearfully for help,#a face quivering with anger!"; _talk_timer = 150; break;
    case 17: spk = 0; txt = "Go, on! Get angry!"; _talk_timer = 40; break;
    case 18: spk = 0; txt = "Suffer! Be sad!"; _talk_timer = 40; break;
    case 19: spk = 0; txt = "That would truly be the ultimate offering to me and my great god!"; _talk_timer = 90; break;
    case 20: spk = 2; txt = "Your god?"; _talk_timer = 60; break;
    case 21: spk = 2; txt = "Zio! Do you understand what's going on?"; _talk_timer = 90; break;
    case 22: spk = 2; txt = "If we don't stop the systems that are running out of control,#the world itself is going to become uninhabitable."; _talk_timer = 150; break;
    case 23: spk = 2; txt = "You must let us-"; _talk_timer = 20; break;
    case 24: spk = 0; txt = "Total annihilation of life,#What a fine thing!"; _talk_timer = 90; break;
    case 25: spk = 0; txt = "Death to all that lives!"; _talk_timer = 60; break;
    case 26: spk = 0; txt = "Destruction to all that has form!"; _talk_timer = 90; break;
    case 27: spk = 0; txt = "That is indeed my desire!"; _talk_timer = 60; break;
    case 28: spk = 1; txt = "That's crazy!"; _talk_timer = 60; break;
    case 29: spk = 0; txt = "My god will not tolerate any life forms in Algo!"; _talk_timer = 90; break;
    case 30: spk = 0; txt = "Everything must be wiped out!"; _talk_timer = 60; break;
    case 31: spk = 0; txt = "And I, with these very hands,#will do just that!"; _talk_timer = 60; break;
    case 32: spk = 1; txt = "Zio, you'd die, too!"; _talk_timer = 30; break;
    case 33: spk = 0; txt = "If my god wishes that to be so,#that is also my wish."; _talk_timer = 90; break;
    case 34: spk = 2; txt = "You... you're out of your mind!"; _talk_timer = 60; break;
    case 35: spk = 0; txt = "Fun and games are over with."; _talk_timer = 60; break;
    case 36: spk = 0; txt = "Anyone who dares get in my way shall perish."; _talk_timer = 60; break;
    case 37: spk = 0; txt = "My humble self, who has taken it upon myself#to do the wish of my god, shall purge you from his sight."; _talk_timer = 150; break;
    case 38: spk = 0; txt = "Oh, the greatest, my one and only ultimate god, DARK FORCE!"; _talk_timer = 60; break;
    case 39: spk = 1; txt = "'Dark Force'?"; _talk_timer = 30; break;
    default:
        // done: on to the battle
        _talk_on = false;
        _cutscenemessage = "";
        with(obj_unit) if(id != other.id) _cutscenemessage = "";
        alarm[7] = 30;
        exit;
}
_talk += 1;
if(spk == 0) u = id;
else if(spk == 1) u = _talk_t1;
else if(spk == 2) u = _talk_t2;
else if(spk == 3) u = _talk_t3;
else u = _talk_t4;
if(!instance_exists(u)) u = id;
// a speaker's previous line goes when they speak again; everyone else's stays up a while
with(obj_unit) {
    if(variable_local_exists("_talk_clear")) {
        _talk_clear -= other._talk_timer;
        if(_talk_clear <= 0 && id != u) _cutscenemessage = "";
    }
}
u._cutscenemessage = txt;
u._talk_clear = max(150, _talk_timer);
