// Undo anything this Paladin still has applied to other units, then do the normal unit cleanup
paladin_release();
ds_list_destroy(_aura_list);
event_inherited();
