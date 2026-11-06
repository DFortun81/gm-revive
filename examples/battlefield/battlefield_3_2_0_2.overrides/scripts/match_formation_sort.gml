// match_formation_sort(list);
// Reorders a ds_list of classes for a formation: front-line classes first (they take the ranks
// nearest the enemy), Casters and Healers last, otherwise keeping the rolled order.
////////////////////////////////////////////////////////////////////////////////////////////
var l, back, i, c;
l = argument0;
back = ds_list_create();
for(i = 0; i < ds_list_size(l); i += 1) {
    c = ds_list_find_value(l, i);
    if(c == class_caster || c == class_healer) {
        ds_list_add(back, c);
        ds_list_delete(l, i);
        i -= 1;
    }
}
for(i = 0; i < ds_list_size(back); i += 1) ds_list_add(l, ds_list_find_value(back, i));
ds_list_destroy(back);
