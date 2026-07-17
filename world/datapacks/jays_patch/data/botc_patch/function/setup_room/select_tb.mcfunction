# Select Trouble Brewing and show its role wall.
tag @s add botc_setup_room_used
function botc_patch:setup/script/trouble_brewing
execute unless score setup_import_success botc_patch matches 1 run return 0
scoreboard players reset setup_import_success botc_patch
function botc_patch:setup/clear_known_roles
function botc_patch:setup/apply_silent
function botc_patch:setup_wall/show_tb
function botc_patch:setup_room/give_action_controls
playsound minecraft:block.note_block.pling voice @s ~ ~ ~ 0.7 1.1
