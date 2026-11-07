// zio_barrier_factor(zio, attacker);
// How hard a hit lands on Zio's Magic Barrier: 4 for holy power (anything a Paladin or Healer does:
// Crusader Strike, Judgement, Consecration, Smite), 0.15 for everything else. A holy hit also flashes
// gold and white on the barrier now and then. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
var z, a, holy, p;
z = argument0; a = argument1;
holy = false;
if(instance_exists(a)) {
    if(object_is_ancestor(a.object_index, obj_unit) || a.object_index == obj_unit) {
        if(a._jobclass == class_paladin || a._jobclass == class_healer) holy = true;
    }
}
if(!holy) return 0.15;
if(current_time - z._last_holy > 1500) {
    z._last_holy = current_time;
    p = fx_make(0, z.x, z.y, z.sprite_height * 0.55, make_color_rgb(255, 235, 150), 0.7, 12);
    p = fx_make(6, z.x + random_range(-8, 8), z.y, random_range(10, z.sprite_height), c_white, 0.35, 14); p._spin = 20;
    create_text_effect(z.x, z.y, c_yellow, "-holy light pierces the barrier-");
}
return 4;
