// When the Broodmother dies, her brood dies with her
if(_health <= 0 && !dead) {
    with(obj_broodling) if(_mother == other.id && !dead) { _mother = -1; _health = 0; dead = true; } // not counted as killed
}
event_inherited();
