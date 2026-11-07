// Count Vaelric (gm-revive overrides): the 2013 "Elmdor" fight, rebranded as a vampire lord when the
// real Marquis Elmdor became his own raid boss (obj_boss_marquis). Same mechanics; only the lines and
// spell names changed: Muramasa is Crimson Tempest, Masamune is Sanguine Lance, Teleport is Mist Step.
var ds, f;
f = ds_list_size(ds_list_find_value(global.faction_agents, 0)) < ds_list_size(ds_list_find_value(global.faction_agents, 1));
ds = ds_list_find_value(global.faction_agents, f);
_target = ds_list_find_value(ds, floor(random(ds_list_size(ds)))); 
_target._cutscenemessage = "Where are the villagers you took, monster?!";
alarm[3] = 140;