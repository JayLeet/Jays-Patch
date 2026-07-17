# Select the same setup-menu role scores that the individual checkbox buttons use.
execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup commands are disabled while a game is live.","color":"gray","bold":false}]
function botc_patch:setup/script/trouble_brewing
execute unless score setup_import_success botc_patch matches 1 run return 0
scoreboard players reset setup_import_success botc_patch
function botc_patch:setup/clear_known_roles
scoreboard players set washerwoman role_list 1
scoreboard players set librarian role_list 1
scoreboard players set investigator role_list 1
scoreboard players set chef role_list 1
scoreboard players set empath role_list 1
scoreboard players set fortune_teller role_list 1
scoreboard players set undertaker role_list 1
scoreboard players set monk role_list 1
scoreboard players set ravenkeeper role_list 1
scoreboard players set virgin role_list 1
scoreboard players set slayer role_list 1
scoreboard players set soldier role_list 1
scoreboard players set mayor role_list 1
scoreboard players set butler role_list 1
scoreboard players set drunk role_list 1
scoreboard players set recluse role_list 1
scoreboard players set saint role_list 1
scoreboard players set poisoner role_list 1
scoreboard players set spy role_list 1
scoreboard players set scarlet_woman role_list 1
scoreboard players set baron role_list 1
scoreboard players set imp role_list 1
function ct:admin/setup/set_from_menu
tellraw @s [{"text":"Selected preset: ","color":"gray"},{"text":"Trouble Brewing","color":"yellow"}]
