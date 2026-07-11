execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup commands are disabled while a game is live.","color":"gray","bold":false}]
execute if score @s botc_setup_bridge_cd matches 1.. run return 0
scoreboard players set @s botc_setup_bridge_cd 8
function botc_patch:setup/preset/sects_and_violets
