execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup signs are disabled while a game is live.","color":"gray","bold":false}]

execute if entity @s[tag=!storyteller] run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":" You are now the Storyteller.","color":"gray","bold":false}]
execute if entity @s[tag=!storyteller] run tellraw @a[tag=storyteller] [{"text":"! ","color":"yellow","bold":true},{"selector":"@s","bold":false,"color":"white"},{"text":" is now a Storyteller.","color":"gray","bold":false}]
execute if entity @s[tag=storyteller] run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":" You are already the Storyteller.","color":"gray","bold":false}]

team leave @s[team=00_spectator]
tag @s remove spectator
team join 99_storyteller @s
tag @s add storyteller
fmvariable set storyteller false true
gamemode adventure @s
