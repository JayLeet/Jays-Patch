# Select the same setup-menu role scores that the individual checkbox buttons use.
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"You can't use setup commands while a game is live.","color":"gray","bold":false}]
function botc_patch:setup/script/bad_moon_rising
execute unless score setup_import_success botc_patch matches 1 run return 0
scoreboard players reset setup_import_success botc_patch
function botc_patch:setup/clear_known_roles
scoreboard players set grandmother role_list 1
scoreboard players set sailor role_list 1
scoreboard players set chambermaid role_list 1
scoreboard players set exorcist role_list 1
scoreboard players set innkeeper role_list 1
scoreboard players set gambler role_list 1
scoreboard players set gossip role_list 1
scoreboard players set courtier role_list 1
scoreboard players set professor role_list 1
scoreboard players set minstrel role_list 1
scoreboard players set tea_lady role_list 1
scoreboard players set pacifist role_list 1
scoreboard players set fool role_list 1
scoreboard players set tinker role_list 1
scoreboard players set moonchild role_list 1
scoreboard players set goon role_list 1
scoreboard players set lunatic role_list 1
scoreboard players set godfather role_list 1
scoreboard players set devils_advocate role_list 1
scoreboard players set assassin role_list 1
scoreboard players set mastermind role_list 1
scoreboard players set zombuul role_list 1
scoreboard players set pukka role_list 1
scoreboard players set shabaloth role_list 1
scoreboard players set po role_list 1
function ct:admin/setup/set_from_menu
tellraw @s [{"text":"Selected preset: ","color":"gray"},{"text":"Bad Moon Rising","color":"yellow"}]
