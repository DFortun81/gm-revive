// Count Vaelric (gm-revive overrides): the 2013 "Elmdor" fight, rebranded as a vampire lord when the
// real Marquis Elmdor became his own raid boss (obj_boss_marquis). Same mechanics; only the lines and
// spell names changed: Muramasa is Crimson Tempest, Masamune is Sanguine Lance, Teleport is Mist Step.
if(_overlay_alpha < 0.99) {
    image_single = 0;
    _overlay_alpha += (1 - _overlay_alpha) / 30;
    if(_overlay_alpha > 0.6 && _overlay_alpha < 0.66) {
        _cutscenemessage = "Oh, why... Why does the dark abandon me?";
        alarm[10] = 120;
    }
    alarm[9] = 2;
}