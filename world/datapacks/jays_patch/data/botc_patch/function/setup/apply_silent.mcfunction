# Rebuild Sybillian's setup role storage from the selected role_list scores.
function ct:admin/setup/set_from_menu
execute if score wraith role_list matches 1 run data modify storage ct:roles roles insert 0 value {id:325,name:"Wraith"}
