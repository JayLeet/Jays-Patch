# Apply setup, start night one through Sybillian, then announce roles to players.
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Start is disabled while a game is live.","color":"gray","bold":false}]
tag @s add botc_setup_room_used
tag @s remove botc_setup_room_active
function botc_patch:setup/apply_silent
function botc_patch:setup_wall/clear_highlights
function botc_patch:cmd/start
function botc_patch:storyteller_tools/teleport_den
function botc_patch:setup_room/play_start_bell
schedule function botc_patch:setup_room/start_role_reveal 3s replace
