# Apply the current role wall selection to Sybillian's setup storage.
tag @s add botc_setup_room_used
function botc_patch:setup/apply
function botc_patch:setup_wall/refresh
function botc_patch:setup_room/give_action_controls
playsound minecraft:block.note_block.pling voice @s ~ ~ ~ 0.7 1.35
