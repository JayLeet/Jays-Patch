execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup commands are disabled while a game is live.","color":"gray","bold":false}]
data remove storage botc_patch:setup import_payload
$data modify storage botc_patch:setup import_payload set value $(script)
function botc_patch:setup/import/commit
execute unless score setup_import_success botc_patch matches 1 run return 0
scoreboard players reset setup_import_success botc_patch
function botc_patch:setup/clear_known_roles
function botc_patch:setup/apply_silent
function botc_patch:setup_wall/show_current
function botc_patch:setup_room/give_action_controls
tellraw @s [{"text":"Imported custom setup script.","color":"yellow"}]
