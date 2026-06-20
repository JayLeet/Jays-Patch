execute unless score phase game_data matches 0 run return run tellraw @s [{"text":"! ","color":"red","bold":true},{"text":"Setup signs are disabled while a game is live.","color":"gray","bold":false}]

execute unless entity @s[tag=storyteller] unless entity @s[tag=spectator] run tellraw @s [{"text":"! ","color":"yellow","bold":true},{"text":" You are already sitting as a player.","color":"gray","bold":false}]

execute if entity @s[tag=storyteller] run function ct:cmd/storyteller/remove {target:"The sign user"}
execute if entity @s[tag=spectator] run function ct:cmd/spectator/remove {target:"The sign user"}
