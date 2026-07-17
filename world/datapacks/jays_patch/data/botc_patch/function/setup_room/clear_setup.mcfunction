# Clear all selected setup roles and sync Sybillian's role storage.
tag @s add botc_setup_room_used
function botc_patch:setup/clear
function botc_patch:setup_wall/refresh
function botc_patch:setup_room/give_action_controls
playsound minecraft:block.note_block.bass voice @s ~ ~ ~ 0.6 0.6
