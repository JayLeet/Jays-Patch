# Select the same setup-menu role scores that the individual checkbox buttons use.
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
function botc_patch:setup/script/sects_and_violets
execute unless score setup_import_success botc_patch matches 1 run return 0
scoreboard players reset setup_import_success botc_patch
function botc_patch:setup/clear_known_roles
scoreboard players set clockmaker role_list 1
scoreboard players set dreamer role_list 1
scoreboard players set snake_charmer role_list 1
scoreboard players set mathematician role_list 1
scoreboard players set flowergirl role_list 1
scoreboard players set town_crier role_list 1
scoreboard players set oracle role_list 1
scoreboard players set savant role_list 1
scoreboard players set seamstress role_list 1
scoreboard players set philosopher role_list 1
scoreboard players set artist role_list 1
scoreboard players set juggler role_list 1
scoreboard players set sage role_list 1
scoreboard players set mutant role_list 1
scoreboard players set sweetheart role_list 1
scoreboard players set barber role_list 1
scoreboard players set klutz role_list 1
scoreboard players set evil_twin role_list 1
scoreboard players set witch role_list 1
scoreboard players set cerenovus role_list 1
scoreboard players set pit_hag role_list 1
scoreboard players set fang_gu role_list 1
scoreboard players set vigormortis role_list 1
scoreboard players set no_dashii role_list 1
scoreboard players set vortox role_list 1
function ct:admin/setup/set_from_menu
tellraw @s [{"text":"Selected preset: ","color":"gray"},{"text":"Sects and Violets","color":"yellow"}]
