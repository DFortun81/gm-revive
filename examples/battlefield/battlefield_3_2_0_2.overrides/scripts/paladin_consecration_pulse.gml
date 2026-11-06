// paladin_consecration_pulse(x, y, range);
// One golden pulse of Consecration: a glowing disc that spreads across the consecrated ground and fades.
// Uses the game's obj_pulse (depth 1, additive), so it draws underneath the units.
/////////////////////////////////////////////////////////////////////////////////////////////////////
with(instance_create(argument0, argument1, obj_pulse)) {
    image_blend = make_color_rgb(255, 200, 40);
    _range = argument2;
}
