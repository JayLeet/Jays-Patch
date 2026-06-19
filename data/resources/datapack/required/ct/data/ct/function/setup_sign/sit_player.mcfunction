execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup signs are disabled while a game is live.","color":"gray","bold":false}]

execute if entity @s[tag=storyteller] run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":" You are now sitting as a player.","color":"gray","bold":false}]
execute if entity @s[tag=spectator] run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":" You are now sitting as a player.","color":"gray","bold":false}]
execute unless entity @s[tag=storyteller] unless entity @s[tag=spectator] run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":" You are already sitting as a player.","color":"gray","bold":false}]

tag @s remove storyteller
tag @s remove spectator
team leave @s
fmvariable set storyteller false false
gamemode adventure @s
