// unit_dist(a, b);
// The distance between two units measured edge to edge: centre to centre less both hit boxes (see
// unit_hitbox), never below 0. Like formula_distance_between in Call to Arms. (gm-revive overrides)
////////////////////////////////////////////////////////////////////////////////////////////
return max(0, point_distance(argument0.x, argument0.y, argument1.x, argument1.y) - unit_hitbox(argument0) - unit_hitbox(argument1));
